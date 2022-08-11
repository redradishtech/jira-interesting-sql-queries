-- Iterates through all permission schemes, and prints the users granted permissions. This involves dereferencing group and role memberships.
-- @requires queries
-- @provides queries.userpermissions
create or replace view queries.userpermissions AS
WITH cwd_user AS (select * from cwd_user where active=1),
na AS
  (SELECT *
   FROM nodeassociation
   WHERE source_node_entity='Project'
     AND sink_node_entity='PermissionScheme'),
     perms AS
  (SELECT project.id AS projectid,
          project.pkey,
          sp.*
   FROM project
   JOIN na ON na.source_node_id=project.id
   JOIN permissionscheme ps ON ps.id=na.sink_node_id
   JOIN schemepermissions sp ON sp.scheme=ps.id
 -- WHERE permission_key='MANAGE_SPRINTS_PERMISSION'
   ),
     directuserperms AS
  (SELECT projectid,
          pkey,
          permission_key,
          'user' AS via,
          perm_parameter AS lower_user_name
   FROM perms
   WHERE perm_type='user'),
     groupperms AS
  (SELECT projectid,
          pkey,
          permission_key,
          'group_' || lower(perm_parameter) AS via,
          lower(perm_parameter) AS lower_group_name
   FROM perms
   WHERE perm_type='group'),
     roleperms AS
  (SELECT *
   FROM perms
   WHERE perm_type='projectrole'),
     ROLES AS
  (SELECT roleperms.*,
          projectroleactor.*
   FROM roleperms
   JOIN projectroleactor ON (projectroleactor.pid = projectid
                             AND projectroleactor.projectroleid=roleperms.perm_parameter::integer)),
	grouproleperms AS
  (SELECT projectid,
          pkey,
          permission_key,
          'role_' || lower(roletypeparameter)  AS via,
          lower(roletypeparameter) AS lower_group_name
   FROM ROLES
   WHERE roletype='atlassian-group-role-actor'),
                                                                                                     allgroups AS
  (SELECT *
   FROM grouproleperms
   UNION SELECT *
   FROM groupperms),
                                                                                                     groupandroleusers AS
  (SELECT pkey,
          permission_key,
          via,
          cwd_user.lower_user_name
   FROM allgroups
   JOIN cwd_group USING (lower_group_name)
   JOIN cwd_membership ON cwd_membership.parent_id=cwd_group.id
   JOIN cwd_user ON cwd_user.id=cwd_membership.child_id),
                                                                                                     directusers AS
  (SELECT pkey,
          permission_key,
          via,
          cwd_user.lower_user_name
   FROM directuserperms
   JOIN cwd_user USING (lower_user_name)),
                                                                                                     projectleadusers AS
  (SELECT perms.pkey,
          permission_key,
          'lead' AS via,
          project.lead AS lower_user_name
   FROM project
   JOIN
     (SELECT *
      FROM perms
      WHERE perm_type='lead') AS perms ON perms.projectid=project.id)
, allusers AS
(select * from directusers union select * from groupandroleusers UNION select * from projectleadusers) 
SELECT allusers.*, app_user.user_key
from allusers JOIN app_user USING (lower_user_name);
