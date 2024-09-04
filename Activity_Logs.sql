set serveroutput on;
create table activity_logs
(
Activity_date date,
Username varchar2(25),
Table_name varchar2(50),
Avtivity_type varchar2(10),
Activity_row varchar2(20)
);

--- == trigger monitorujacy aktywnosc dla tabebli GENSHIN_CHAR_ORIGINAL ==
create or replace trigger Genshin_Char_Activity
before insert or update or delete on GENSHIN_CHAR_ORIGINAL
for each row enable
BEGIN
case
when INSERTING then
insert into activity_logs values(sysdate,sys_context('userenv','current_user'),'GENSHIN_CHAR_ORIGINAL','INSERT',:old.rowid);
when DELETING then
insert into activity_logs values(sysdate,sys_context('userenv','current_user'),'GENSHIN_CHAR_ORIGINAL','DELETE',:old.rowid);
when UPDATING then
insert into activity_logs values(sysdate,sys_context('userenv','current_user'),'GENSHIN_CHAR_ORIGINAL','UPDATE',:old.rowid);
end case;
END;

--- == trigger monitorujacy aktywnosc dla tabebli GENSHIN_WEAPOS_ORIGINAL ==
create or replace trigger Genshin_WEAPONS_ACTIVITY
before insert or update or delete on GENSHIN_WEAPONS_ORIGINAL
for each row enable
BEGIN
case
when INSERTING then
insert into activity_logs values(sysdate,sys_context('userenv','current_user'),'GENSHIN_WEAPONS_ORIGINAL','INSERT',:old.rowid);
when DELETING then
insert into activity_logs values(sysdate,sys_context('userenv','current_user'),'GENSHIN_WEAPONS_ORIGINAL','DELETE',:old.rowid);
when UPDATING then
insert into activity_logs values(sysdate,sys_context('userenv','current_user'),'GENSHIN_WEAPONS_ORIGINAL','UPDATE',:old.rowid);
end case;
END;

--- == trigger monitorujacy aktywnosc dla tabebli CHAR_STATISTICS ==
create or replace trigger STATISTICS_ACTIVITY
before insert or update or delete on CHAR_STATISTICS
for each row enable
BEGIN
case
when INSERTING then
insert into activity_logs values(sysdate,sys_context('userenv','current_user'),'CHAR_STATISTICS','INSERT',:old.rowid);
when DELETING then
insert into activity_logs values(sysdate,sys_context('userenv','current_user'),'CHAR_STATISTICS','DELETE',:old.rowid);
when UPDATING then
insert into activity_logs values(sysdate,sys_context('userenv','current_user'),'CHAR_STATISTICS','UPDATE',:old.rowid);
end case;
END;

-- == trigger monitorujacy baze danych == ---
create or replace TRIGGER Base_DDL_ACTIVITY
BEFORE DDL ON DATABASE 
BEGIN
insert into activity_logs values(sysdate,sys_context('userenv','current_user'),ora_dict_obj_name,ora_sysevent,null);
END;

-- test dzialania triggerow --
update GENSHIN_CHAR_ORIGINAL set CHARACTER_NAME='Ganyu' where CHARACTER_NAME='Ganyu';
select * from activity_logs;