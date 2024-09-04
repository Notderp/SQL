set serveroutput on;
-- normalizacja tabeli broni --
-- ===== poprawki danych tabeli ===

-- uzupelnianie brakujacych danych o srednia z istniejacych
select TYPE, round(avg(BASEATTACK),0) from GENSHIN_WEAPONS_ORIGINAL where BASEATTACK IS NOT NULL group by TYPE;
update GENSHIN_WEAPONS_ORIGINAL set BASEATTACK = 41 where BASEATTACK IS NULL and TYPE='Sword';
update GENSHIN_WEAPONS_ORIGINAL set BASEATTACK = 41 where BASEATTACK IS NULL and TYPE='Bow';
update GENSHIN_WEAPONS_ORIGINAL set BASEATTACK = 41 where BASEATTACK IS NULL and TYPE='Claymore';
update GENSHIN_WEAPONS_ORIGINAL set BASEATTACK = 41 where BASEATTACK IS NULL and TYPE='Catalyst';
update GENSHIN_WEAPONS_ORIGINAL set BASEATTACK = 42 where BASEATTACK IS NULL and TYPE='Polearm';

-- Uzupelnianie brakujacych nazw i opisow --
select  WEAPONID,PASSIVENAME,PASSIVEDESC from GENSHIN_WEAPONS_ORIGINAL where PASSIVENAME is null;
update GENSHIN_WEAPONS_ORIGINAL set PASSIVENAME = 'Undying Admiration' where WEAPONID=40;
update GENSHIN_WEAPONS_ORIGINAL set PASSIVENAME = 'Frost Burial' where WEAPONID=43;
update GENSHIN_WEAPONS_ORIGINAL set PASSIVENAME = 'Golden Majesty' where WEAPONID=111;

update genshin_weapons_original set ascensionmaterial = 'unknown material' where ascensionmaterial is null;

select DISTINCT PASSIVENAME,SUBSTAT, PASSIVEDESC  from GENSHIN_WEAPONS_ORIGINAL order by PASSIVENAME; 

-- ==== TWORZENIE tabeli z pasywkami broni ====
create table Weapons_Passives (
PASSIVEID number,
PASSIVENAME Varchar2(128),
PASSIVEDESC Varchar2(1024)
);
-- == Uzupelnianie nowe tabeli istniejacymi danymi ==

create sequence passive_seq
minvalue 1
maxvalue 999999
start with 1 
increment by 1
cache 20;

BEGIN
for Pasywka in (SELECT DISTINCT PASSIVENAME, PASSIVEDESC FROM GENSHIN_WEAPONS_ORIGINAL)
loop
insert into weapons_passives values (passive_seq.nextval, Pasywka.PASSIVENAME, Pasywka.PASSIVEDESC);
end loop;
END;

-- == powiazanie tabel wspolna wartoscia == 

alter table GENSHIN_WEAPONS_ORIGINAL add PASSIVE_FK number;
BEGIN
for pasywka in 
(select GENSHIN_WEAPONS_ORIGINAL.WEAPONID,GENSHIN_WEAPONS_ORIGINAL.PASSIVENAME,weapons_passives.PASSIVEID
from GENSHIN_WEAPONS_ORIGINAL 
left join weapons_passives on GENSHIN_WEAPONS_ORIGINAL.PASSIVEDESC = weapons_passives.PASSIVEDESC)
loop
update genshin_weapons_original set PASSIVE_FK=pasywka.PASSIVEID where genshin_weapons_original.WEAPONID=pasywka.WEAPONID;
end loop;
END;

-- == powiazanie tabel kluczami ==
alter table GENSHIN_WEAPONS_ORIGINAL add constraint Weapon_pk primary key (WEAPONID);
alter table weapons_passives add constraint Passive_pk primary key (passiveid);
alter table GENSHIN_WEAPONS_ORIGINAL add constraint Weapon_passive_fk foreign key (Passive_fk) references weapons_passives (PassiveID);

-- == usuniecie zbednych danych i sprawdzenie ==
alter table GENSHIN_WEAPONS_ORIGINAL drop column PASSIVENAME;
alter table GENSHIN_WEAPONS_ORIGINAL drop column PASSIVEDESC;
select * from genshin_weapons_original left join weapons_passives on GENSHIN_WEAPONS_ORIGINAL.passive_fk=weapons_passives.passiveid;