
insert into dict_en (page_name) select page_name from dict_en on conflict do nothing;

insert into dict_en (page_name) select 'blub' as page_name on conflict do update returning *;
insert into dict_en (page_name) select 'blub' as page_name on conflict (page_name) do update set page_name = EXCLUDED.page_name returning *;
select unnest(array['1','2','3'])::integer as dings;

with inserted_dicts as
  (
    insert into tmp (page_name)
      select page_name from dict_en
        limit 10
        on conflict (page_name)
            do update set page_name = EXCLUDED.page_name
            returning *
  )
insert into tmp_source
  select page_name, '2018-01-01' as page_date
    from inserted_dicts
;




with inserted_dicts as
  (
    INSERT INTO dict_en (page_name) VALUES (?)
        ON CONFLICT (page_name)
          DO UPDATE
            SET page_name = EXCLUDED.page_name
          RETURNING *
  )
INSERT INTO tmp_source
  SELECT page_name, '?' AS page_date
    FROM inserted_dicts
;
