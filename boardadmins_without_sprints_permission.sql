-- Identifies administrators of Boards who lack 'Manage Sprints' permission in all projects - and therefore will not be able to start Sprints in the Boards they allegedly manage.
-- @requires queries.userpermissions
-- @provides queries.boardadmins_without_sprints_permission
create or replace view queries.boardadmins_without_sprints_permission AS
WITH 
rapidview AS (SELECT "AO_60DB71_RAPIDVIEW"."CARD_COLOR_STRATEGY" AS card_color_strategy,
    "AO_60DB71_RAPIDVIEW"."ID" AS id,
    "AO_60DB71_RAPIDVIEW"."NAME" AS name,
    "AO_60DB71_RAPIDVIEW"."OWNER_USER_NAME" AS owner_user_name,
    "AO_60DB71_RAPIDVIEW"."SAVED_FILTER_ID" AS saved_filter_id,
    "AO_60DB71_RAPIDVIEW"."SPRINTS_ENABLED" AS sprints_enabled,
    "AO_60DB71_RAPIDVIEW"."SPRINT_MARKERS_MIGRATED" AS sprint_markers_migrated,
    "AO_60DB71_RAPIDVIEW"."SWIMLANE_STRATEGY" AS swimlane_strategy,
    "AO_60DB71_RAPIDVIEW"."SHOW_DAYS_IN_COLUMN" AS show_days_in_column,
    "AO_60DB71_RAPIDVIEW"."KAN_PLAN_ENABLED" AS kan_plan_enabled,
    "AO_60DB71_RAPIDVIEW"."SHOW_EPIC_AS_PANEL" AS show_epic_as_panel,
    "AO_60DB71_RAPIDVIEW"."OLD_DONE_ISSUES_CUTOFF" AS old_done_issues_cutoff,
    "AO_60DB71_RAPIDVIEW"."REFINED_VELOCITY_ACTIVE" AS refined_velocity_active
   FROM "AO_60DB71_RAPIDVIEW" WHERE "SPRINTS_ENABLED"=true),
boardadmins AS (SELECT "AO_60DB71_BOARDADMINS"."ID" AS id,
	    "AO_60DB71_BOARDADMINS"."KEY" AS key,
	    "AO_60DB71_BOARDADMINS"."RAPID_VIEW_ID" AS rapid_view_id,
	    "AO_60DB71_BOARDADMINS"."TYPE" AS type
	   FROM "AO_60DB71_BOARDADMINS") select distinct '[~'||lower_user_name||'|/secure/admin/user/EditUserGroups!default.jspa?name='||lower_user_name||']', string_agg(boardurl, ', ') AS boards from (select lower_user_name, '['||name||'|/secure/RapidView.jspa?rapidView='||rapid_view_id||']' AS boardurl  from boardadmins JOIN rapidview ON rapidview.id=boardadmins.rapid_view_id JOIN app_user ON app_user.user_key=boardadmins.key JOIN cwd_user USING (lower_user_name) where cwd_user.active=1 and not exists (select * From queries.userpermissions WHERE userpermissions.user_key=boardadmins.key AND permission_key='MANAGE_SPRINTS_PERMISSION')) x group by 1;
