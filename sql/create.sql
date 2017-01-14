-- create.sql


--
-- Schemas
--

create schema import;


--
-- Types
--

create domain municipality_name varchar (255);
create domain site_name varchar(255);
create domain site_type_name varchar(255);


--
-- Functions
--

create function array_to_set(anyarray) returns setof anyelement as $$
  select a[i] from (select generate_subscripts($1, 1) as i, $1 as a) as t;
$$ language sql immutable;


--
-- Base Relvars
--

create table municipality
( m_name municipality_name primary key
, m_geometry geometry not null
);

create table import.municipality
( m_name municipality_name primary key
);

create table site_type
( st_name site_type_name primary key
);

insert into site_type (st_name) values
  ('Featured site')   -- 1
, ('Museum/Archives') -- 2
, ('Building')        -- 3
, ('Monument')        -- 4
, ('Cemetery')        -- 5
, ('Location')        -- 6
, ('Other')           -- 7
;

create table site
( s_no integer primary key
, s_name site_name not null                                                   -- site
, m_name municipality_name not null references municipality on update cascade -- describe
, s_address text not null                                                     -- location, number
, st_name site_type_name not null references site_type on update cascade      -- first sitetype
, s_keyword varchar(255) not null
, s_url varchar(255) not null                                                 -- file
, s_published_p boolean not null                                              -- site, preceded by </A> if record hyperlink is to be ignored
);

create table site_secondary_site_type
( s_no integer not null references site on update cascade
, st_name site_type_name not null references site_type on update cascade       -- sitetype
);

create table import.site
( s_no integer primary key
, s_name site_name not null                                                          -- site
, m_name municipality_name not null references import.municipality on update cascade -- describe
, s_address text not null                                                            -- location, number
, st_name site_type_name not null references site_type on update cascade             -- first sitetype
, s_keyword varchar(255) not null
, s_url varchar(255) not null                                                        -- file
, s_published_p boolean not null                                                     -- site, preceded by </A> if record hyperlink is to be ignored
);

create table import.site_secondary_site_type
( s_no integer not null references import.site on update cascade
, st_name site_type_name not null references site_type on update cascade       -- sitetype
);

-- lat, lng
create table site_geo
( s_no integer primary key references site on update cascade on delete cascade
, sg_geometry geometry not null
, sg_geography geography not null
);

create index site_geo_sg_geometry_gix on site_geo using gist (sg_geometry);
create index site_geo_sg_geography_gix on site_geo using gist (sg_geography);

-- lat, lng
create table import.site_geo
( s_no integer primary key references import.site on update cascade on delete cascade
, sg_geometry geometry not null
, sg_geography geography not null
);

-- N
create table site_national_designation
( s_no integer primary key references site on update cascade on delete cascade
, snd_no varchar(255) not null 
);

-- N
create table import.site_national_designation
( s_no integer primary key references import.site on update cascade on delete cascade
, snd_no varchar(255) not null 
);

-- P
create table site_provincial_designation
( s_no integer primary key references site on update cascade on delete cascade
, spd_no varchar(255) not null 
);

-- P
create table import.site_provincial_designation
( s_no integer primary key references import.site on update cascade on delete cascade
, spd_no varchar(255) not null 
);

-- M
create table site_municipal_designation
( s_no integer primary key references site on update cascade on delete cascade
, smd_no varchar(255) not null 
);

-- M
create table import.site_municipal_designation
( s_no integer primary key references import.site on update cascade on delete cascade
, smd_no varchar(255) not null 
);


--
-- Derived Relvars and Functions
--

create function clear_import () returns void as $$
begin
  delete from import.site_national_designation;
  delete from import.site_provincial_designation;
  delete from import.site_municipal_designation;
  delete from import.site_geo;
  delete from import.site_secondary_site_type;
  delete from import.site;
  delete from import.municipality;
end;
$$ language plpgsql;

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
      -- X, Y == longitude, latitude (not latitude, longitude)
      insert into import.site_geo
      ( s_no
      , sg_geometry
      , sg_geography)
      values
      ( a_s_no
      , st_setsrid(st_point(a_lng, a_lat), 4326)
      , geography(st_transform(st_setsrid(st_point(a_lng, a_lat), 4326), 4326)));
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
