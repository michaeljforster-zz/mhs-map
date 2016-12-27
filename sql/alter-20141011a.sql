-- alter-20141011a.sql

alter table site add column s_keyword varchar(255);
update site set s_keyword = '';
alter table site alter column s_keyword set not null;

alter table import.site add column s_keyword varchar(255);
update import.site set s_keyword = '';
alter table import.site alter column s_keyword set not null;

drop function import_site ( a_s_no integer
                          , a_s_name site_name
                          , a_m_name municipality_name
                          , a_s_address text
                          , a_st_names anyarray
                          , a_s_url varchar
                          , a_s_published_p boolean
                          , a_lat double precision
                          , a_lng double precision
                          , a_snd_no varchar
                          , a_spd_no varchar
                          , a_smd_no varchar );

create function import_site ( a_s_no integer
                            , a_s_name site_name
                            , a_m_name municipality_name
                            , a_s_address text
                            , a_st_names anyarray
                            , a_s_keyword varchar
                            , a_s_url varchar
                            , a_s_published_p boolean
                            , a_lat double precision
                            , a_lng double precision
                            , a_snd_no varchar
                            , a_spd_no varchar
                            , a_smd_no varchar )
returns void as $$
begin

  if not exists (select true from import.municipality where m_name = a_m_name) then
      insert into import.municipality (m_name) values (a_m_name);
  end if;
  insert into import.site (s_no, s_name, m_name, s_address, st_name, s_keyword, s_url, s_published_p)
  values (a_s_no, a_s_name, a_m_name, a_s_address, (select t.st_name from array_to_set(a_st_names[1:1]) as t(st_name)), a_s_keyword, a_s_url, a_s_published_p);
  insert into import.site_secondary_site_type (s_no, st_name)
  select a_s_no, t.st_name from array_to_set(a_st_names[2:array_upper(a_st_names, 1)]) as t(st_name);
  if a_lat is not null and a_lng is not null then
      insert into import.site_geometry (s_no, sg_geometry)
      values (a_s_no, st_makepoint(a_lng, a_lat)); -- X, Y == longitude, latitude (not latitude, longitude)
  end if;
  if a_snd_no is not null then
      insert into import.site_national_designation (s_no, snd_no) values (a_s_no, a_snd_no);
  end if;
  if a_spd_no is not null then
      insert into import.site_provincial_designation (s_no, spd_no) values (a_s_no, a_spd_no);
  end if;
  if a_smd_no is not null then
      insert into import.site_municipal_designation (s_no, smd_no) values (a_s_no, a_smd_no);
  end if;
end;
$$ language plpgsql;


drop function complete_import ();

create function complete_import () returns void as $$
begin
  if not exists (select true from import.site) then
      raise exception 'No import to complete, aborting';
  end if;
  delete from site_national_designation;
  delete from site_provincial_designation;
  delete from site_municipal_designation;
  delete from site_geometry;
  delete from site_secondary_site_type;
  delete from site;
  delete from municipality;
  insert into municipality (m_name) select m_name from import.municipality;
  insert into site (s_no, s_name, m_name, s_address, st_name, s_keyword, s_url, s_published_p)
  select s_no, s_name, m_name, s_address, st_name, s_keyword, s_url, s_published_p from import.site;
  insert into site_secondary_site_type (s_no, st_name)
  select s_no, st_name from import.site_secondary_site_type;
  insert into site_national_designation (s_no, snd_no)
  select s_no, snd_no from import.site_national_designation;
  insert into site_provincial_designation (s_no, spd_no)
  select s_no, spd_no from import.site_provincial_designation;
  insert into site_municipal_designation (s_no, smd_no)
  select s_no, smd_no from import.site_municipal_designation;
  insert into site_geometry (s_no, sg_geometry)
  select s_no, sg_geometry from import.site_geometry;
end;
$$ language plpgsql;
