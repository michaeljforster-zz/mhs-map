-- alter-20170114a.sql


alter table municipality add column m_geometry geometry;
update municipality as m set m_geometry = (select coalesce(st_centroid(st_multi(st_union(sg_geometry))), 'POINT EMPTY'::geometry) from (select sg_geometry from site join site_geo using (s_no) where m_name = m.m_name) as t0);
alter table municipality alter column m_geometry set not null;


drop function complete_import ();

create function complete_import () returns void as $$
begin
  if not exists (select true from import.site) then
      raise exception 'No import to complete, aborting';
  end if;
  delete from site_national_designation;
  delete from site_provincial_designation;
  delete from site_municipal_designation;
  delete from site_geo;
  delete from site_secondary_site_type;
  delete from site;
  delete from municipality;
  insert into municipality (m_name, m_geometry)
  select m_name, 'POINT EMPTY'::geometry from import.municipality;
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
  insert into site_geo (s_no, sg_geometry, sg_geography)
  select s_no, sg_geometry, sg_geography from import.site_geo;
  update municipality as m set m_geometry =
  ( select coalesce(st_centroid(st_multi(st_union(sg_geometry))), 'POINT EMPTY'::geometry) from
    ( select sg_geometry from site join site_geo using (s_no) where m_name = m.m_name ) as t0 );
end;
$$ language plpgsql;
