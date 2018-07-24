create or replace view
  ost_comments
as
select
  id,
  thread_id,
  created,
  concat(body, "<br /><br />---<br /><br />Commented at ", created, ".<br />Updated at ", updated, ".<br />") as comment
from
  ost_thread_entry
order by id;

create or replace view
  ost_ticket_descriptions
as
select
  t.ticket_id as ticket_id ,
  t.created as created ,
  concat(number, " : ", c.subject) as subject ,
  e.thread_id as thread_id ,
  concat("Original ticket number: ", number, "<br />Questioner: @", name, "<br />Created: ", t.created, "<br />Last updated: ", t.lastupdate, "<br />Closed: ", t.closed, "<br /><br />---<br /><br />", comment) as description
from
  ( ( ( ( ost_ticket t
          join
          ost_ticket__cdata c
          on
          t.ticket_id = c.ticket_id )
        left join
        ost_user u
        on
        t.user_id = u.id )
      left join
      ( select * from ost_thread
        where object_type = 'T' ) as th
      on
      t.ticket_id = th.object_id
      )
    left join
    ( select min(id) as id, thread_id
      from ost_comments
      group by thread_id) as ei
    on
    th.id = ei.thread_id
  )
  left join
  ost_comments as e
  on
  ei.id = e.id;

create or replace view
  ost_task_descriptions
as
select
  t.id as ticket_id ,
  t.created as created ,
  concat(t.number, " : ", c.title) as subject ,
  e.thread_id as thread_id ,
  concat("Original ticket number: ", t.number, "<br />Questioner: @Naoki Sato<br />Created: ", t.created, "<br />Last updated: ", t.updated, "<br />Closed: ", t.closed, "<br /><br />---<br /><br />", comment) as description
from
  ( ( ( ost_task t
        join
        ost_task__cdata c
        on
        t.id = c.task_id )
      left join
      ( select * from ost_thread
        where object_type = 'A' ) as th
      on
      t.id = th.object_id
      )
    left join
    ( select min(id) as id, thread_id
      from ost_comments
      group by thread_id) as ei
    on
    th.id = ei.thread_id
  )
  left join
  ost_comments as e
  on
  ei.id = e.id;

create or replace view
  ost_all_descriptions
as
  select * from ost_ticket_descriptions
  union all
  select * from ost_task_descriptions
  order by created ;

