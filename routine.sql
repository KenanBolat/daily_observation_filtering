select max(m_date ) from daily_aws_filtered daf ;

select max(m_date ) from aws_obs_filter daf ;
select max(m_date) from aws_observation ao;
select max(m_date) from sck_observation ao;

insert into aws_obs_filter(stationid, altitude, m_date, snow_depth, geom) select stationid, altitude, m_date, snow_depth, geom from spa_observation where m_date > '2020-09-22';
insert into spa_obs_filter(stationid, altitude, m_date, snow_depth, geom) select stationid, altitude, m_date, snow_depth, geom from spa_observation where m_date > '2020-09-22';

select * from daily_aws_filtered daf where m_date in (select max(m_date ) from daily_aws_filtered );


REFRESH MATERIALIZED VIEW daily_aws_filtered;
REFRESH MATERIALIZED VIEW daily_spa_filtered;
REFRESH MATERIALIZED VIEW daily_syn_filtered;
REFRESH MATERIALIZED VIEW daily_aws_3857; 
refresh materialized view stations_aws;
REFRESH MATERIALIZED VIEW daily_spa_3857;
refresh materialized view stations_spa;
REFRESH MATERIALIZED VIEW daily_syn_3857;
refresh materialized view stations_syn;
REFRESH MATERIALIZED VIEW daily_sck_3857;
refresh materialized view stations_sck;
refresh materialized view stations_sck_simple;



select * from stations_spa ss ;


select stationid , count(snow_depth ) from aws_obs_filter aof group by stationid order by 2 desc;
select stationid , count(snow_depth ), max(m_date ) from spa_obs_filter aof group by stationid order by 2 desc;



select * from spa_obs_filter sof where stationid = 17777 and m_date > '2020-06-08' order by m_date asc; 


update spa_obs_filter set status = 1 where stationid = 17777;

select count(*) from aws_observation ao where m_date >= '2019-09-30' and m_date <= '2019-10-30' ;
select * from aws_observation ao where snow_depth is null;
select * from spa_observation ao where snow_depth is null;





select count(*) from spa_observation ao where m_date::date> '2018-09-30' and m_date::date <= '2019-09-30' ;
select count(*) from spa_observation ao where m_date::date> '2018-09-30' and m_date::date < '2019-10-01' ;
select count(*) from syn_observation ao where m_date::date> '2019-09-30' and m_date::date < '2020-10-01' ;
select coalesce(nullif(snow_depth, NULL),9999) from spa_observation ao where m_date::date> '2018-09-30' and m_date::date < '2019-10-01' ;


select * from aws_observation ao where stationid = 17569 and status = 0 ;
select * from aws_obs_filter aof where stationid = 17569  ;

update spa_obs_filter set status = 1 where stationid = 17777;

-- Exrport Synoptic Observations from the database  

copy (select stationid, st_x(geom) as x , st_y(geom) as y , 0 as alt, extract(year from m_date) as yearr, extract(month from m_date) as month, extract(day from m_date) as day, extract(hour from m_date) as hour, extract(minute from m_date) as min, coalesce(nullif(snow_depth, NULL), 9999)  from syn_observation where m_date >= '2019-10-01' and m_date<= '2020-10-01') TO '/var/log/postgresql/2019_2020_syn_observation_full.txt' DELIMITER E'\t';


-- Exrport SPA Observations from the database  

copy (select stationid, st_x(geom) as x , st_y(geom) as y , 0 as alt, extract(year from m_date) as yearr, extract(month from m_date) as month, extract(day from m_date) as day, extract(hour from m_date) as hour, extract(minute from m_date) as min, coalesce(nullif(snow_depth, NULL), 9999)  from spa_observation where m_date >= '2019-10-01' and m_date<= '2020-10-01') TO '/var/log/postgresql/2019_2020_spa_observation_full.txt' DELIMITER E'\t';

-- Exrport AWOS Observations from the database  
-- AWOS observations does not contaion null value 

 copy (select stationid, st_x(geom) as x , st_y(geom) as y , 0 as alt, extract(year from m_date) as yearr, extract(month from m_date) as month, extract(day from m_date) as day, extract(hour from m_date) as hour, extract(minute from m_date) as min, snow_depth  from aws_observation where m_date >= '2019-10-01' and m_date<= '2020-10-01') TO '/var/log/postgresql/2019_2020_aws_observation_full.txt' DELIMITER E'\t';