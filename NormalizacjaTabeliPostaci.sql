set serveroutput on;

-- == uzupelnianie danych ==
update GENSHIN_CHAR_ORIGINAL set REGION='Region Unknown' where CHARACTER_NAME like 'Traveler%' or REGION is null;
update GENSHIN_CHAR_ORIGINAL set affiliation='Affiliation Unknown' where CHARACTER_NAME like 'Traveler%';
update GENSHIN_CHAR_ORIGINAL set SPECIAL_DISH='Special Dish Unknown' where CHARACTER_NAME like 'Traveler%';
update GENSHIN_CHAR_ORIGINAL set LIMITED='Not applied' where CHARACTER_NAME like 'Traveler%' or LIMITED IS NULL;
update GENSHIN_CHAR_ORIGINAL set ASCENSION_BOSS_MATERIAL='Not applied' where CHARACTER_NAME like 'Traveler%';
update GENSHIN_CHAR_ORIGINAL set Arkhe='Arkhe Unknown' where Arkhe is null;

-- usuwanie zle zakodowanych znakow z nazw aktorow glosowych 

BEGIN
for aktorzy in (select CHARACTER_NAME as CH, SUBSTR(VOICE_CN,1,instr(VOICE_CN,'(',1,1)-2) as V_CN,
SUBSTR(VOICE_JP,1,instr(VOICE_JP,'(',1,1)-2) as V_JP,
SUBSTR(VOICE_KR,1,instr(VOICE_KR,'(',1,1)-2) as V_KR from GENSHIN_CHAR_ORIGINAL)
loop
update GENSHIN_CHAR_ORIGINAL set voice_cn=aktorzy.V_CN where CHARACTER_NAME=aktorzy.CH;
update GENSHIN_CHAR_ORIGINAL set voice_jp=aktorzy.V_JP where CHARACTER_NAME=aktorzy.CH;
update GENSHIN_CHAR_ORIGINAL set voice_KR=aktorzy.V_KR where CHARACTER_NAME=aktorzy.CH;
end loop;
END;

update GENSHIN_CHAR_ORIGINAL set voice_en='actor uknown' where voice_en is null;
update GENSHIN_CHAR_ORIGINAL set voice_cn='actor uknown' where voice_cn is null;
update GENSHIN_CHAR_ORIGINAL set voice_jp='actor uknown' where voice_jp is null;
update GENSHIN_CHAR_ORIGINAL set voice_kr='actor uknown' where voice_kr is null;

-- oddzielanie danych o aktorach glosowych do osobnej tabeli
create table Voice_actors( 
Actor_id number primary key,
Actor_name Varchar2(20),
Actor_lang Varchar2(20)
);

create sequence Actors_seq
minvalue 1
maxvalue 999999
start with 1 
increment by 1
cache 20;

BEGIN
for aktor in (SELECT DISTINCT VOICE_EN from GENSHIN_CHAR_ORIGINAL)
LOOP
insert into Voice_actors values(Actors_seq.nextval,aktor.VOICE_EN,'English');
END LOOP;

for aktor in (SELECT DISTINCT voice_cn from GENSHIN_CHAR_ORIGINAL)
LOOP
insert into Voice_actors values(Actors_seq.nextval,aktor.VOICE_cn,'Chinese');
END LOOP;

for aktor in (SELECT DISTINCT VOICE_jp from GENSHIN_CHAR_ORIGINAL)
LOOP
insert into Voice_actors values(Actors_seq.nextval,aktor.VOICE_jp,'Japanese');
END LOOP;

for aktor in (SELECT DISTINCT VOICE_kr from GENSHIN_CHAR_ORIGINAL)
LOOP
insert into Voice_actors values(Actors_seq.nextval,aktor.VOICE_kr,'Korean');
END LOOP;

END;

-- ==== powiazanie tabeli wartosciami =======
Alter table GENSHIN_CHAR_ORIGINAL add Voice_English number;
Alter table GENSHIN_CHAR_ORIGINAL add Voice_Chinese number;
Alter table GENSHIN_CHAR_ORIGINAL add Voice_Japanese number;
Alter table GENSHIN_CHAR_ORIGINAL add Voice_Korean number;

BEGIN
for aktorzy in (Select G.Voice_EN,G.VOICE_ENGLISH, A.Actor_name, A.Actor_ID FROM GENSHIN_CHAR_ORIGINAL G left join Voice_actors A on A.Actor_name=G.Voice_en order by Actor_ID)
LOOP
update GENSHIN_CHAR_ORIGINAL set VOICE_ENGLISH=aktorzy.Actor_ID where VOICE_EN=aktorzy.actor_name;
END LOOP;
END;

BEGIN
for aktorzy in (Select G.Voice_CN,G.VOICE_Chinese, A.Actor_name, A.Actor_ID FROM GENSHIN_CHAR_ORIGINAL G left join Voice_actors A on A.Actor_name=G.Voice_cn order by Actor_ID)
LOOP
update GENSHIN_CHAR_ORIGINAL set VOICE_Chinese=aktorzy.Actor_ID where VOICE_CN=aktorzy.actor_name;
END LOOP;
END;

BEGIN
for aktorzy in (Select G.Voice_JP,G.VOICE_Japanese, A.Actor_name, A.Actor_ID FROM GENSHIN_CHAR_ORIGINAL G left join Voice_actors A on A.Actor_name=G.Voice_jp order by Actor_ID)
LOOP
update GENSHIN_CHAR_ORIGINAL set VOICE_Japanese=aktorzy.Actor_ID where VOICE_JP=aktorzy.actor_name;
END LOOP;
END;

BEGIN
for aktorzy in (Select G.Voice_KR,G.VOICE_Korean, A.Actor_name, A.Actor_ID FROM GENSHIN_CHAR_ORIGINAL G left join Voice_actors A on A.Actor_name=G.Voice_kr order by Actor_ID)
LOOP
update GENSHIN_CHAR_ORIGINAL set VOICE_Korean=aktorzy.Actor_ID where VOICE_KR=aktorzy.actor_name;
END LOOP;
END;

-- ==== powiazanie tabeli kluczami =======

alter table GENSHIN_CHAR_ORIGINAL add constraint V_EN_FK foreign key (VOICE_ENGLISH) references voice_Actors (Actor_ID) on delete set null;
alter table GENSHIN_CHAR_ORIGINAL add constraint V_JP_FK foreign key (VOICE_JAPANESE) references voice_Actors (Actor_ID) on delete set null;
alter table GENSHIN_CHAR_ORIGINAL add constraint V_CN_FK foreign key (VOICE_CHINESE) references voice_Actors (Actor_ID) on delete set null;
alter table GENSHIN_CHAR_ORIGINAL add constraint V_KR_FK foreign key (VOICE_KOREAN) references voice_Actors (Actor_ID) on delete set null;

-- === usuniecie zbednych kolumn =====
 
alter table GENSHIN_CHAR_ORIGINAL drop column voice_EN;
alter table GENSHIN_CHAR_ORIGINAL drop column voice_CN;
alter table GENSHIN_CHAR_ORIGINAL drop column voice_JP;
alter table GENSHIN_CHAR_ORIGINAL drop column voice_KR;

-- przenoszenie statystyk do osobnej tabeli ===

alter table GENSHIN_CHAR_ORIGINAL add statistics_ID number; 
create table CHAR_Statistics ( Stats_ID number );

--<kopiowanie reszty kolumn z tabeli z postaciami z poziomu interfejsu>

create sequence Statistics_seq
minvalue 1
maxvalue 999999
start with 1 
increment by 1
cache 20;

BEGIN
for statystyka in (select CHARACTER_NAME FROM GENSHIN_CHAR_ORIGINAL)
LOOP
UPDATE GENSHIN_CHAR_ORIGINAL set statistics_ID = Statistics_seq.nextval where CHARACTER_NAME=statystyka.CHARACTER_NAME;
END LOOP;
END;

insert into CHAR_STATISTICS select <nazwy wszystkich potrzebnych kolumn>; 
alter table CHAR_STATISTICS add constraint stats_pk primary key (STATS_ID);
alter table GENSHIN_CHAR_ORIGINAL add constraint stats_fk foreign key (statistics_ID) references CHAR_statistics (STATS_ID) on delete set null;
--<usuniecie kolumn z poziomu interfejsu> 
