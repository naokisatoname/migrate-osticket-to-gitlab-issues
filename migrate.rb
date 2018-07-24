#!/usr/local/bin/ruby

require 'rubygems'
require 'gitlab'
require 'mysql2'
require 'yaml'

### Load configuration

c = Hash.new

c['gitlab_client_endpoint'] = \
  'https://your.gitlab.server.addr/api/v4'
c['gitlab_client_privatetoekn'] = \
  'YOUR-PRIVATE-GITLAB-TOKEN'
c['gitlab_project'] = \
  'your-name/your-project-name'
c['gitlab_assigneeid'] = \
  0
c['gitlab_milestoneid'] = \
  0
c['gitlab_labels'] = \
  'osticket'

c['mysql_client_host'] = \
  'your.mysql.server.addr'
c['mysql_client_port'] = \
  '3306'
c['mysql_client_username'] = \
  'osticket'
c['mysql_client_password'] = \
  'OSTICKET-USER-PASSWORD'
c['mysql_client_database'] = \
  'osticket'

begin
  c = YAML.load_file('./config/config.yml')
rescue Errno::ENOENT
  puts 'WARNING: Config file not found. The default config settings used.'
end


### Pass the configurations

gitlab_project = c.fetch('gitlab_project')
gitlab_issue_opts_tmpl = Hash.new

if c.fetch('gitlab_assigneeid') > 0 then
  gitlab_issue_opts_tmpl['assignee_id'] = c.fetch('gitlab_assigneeid')
end
if c.fetch('gitlab_milestoneid') > 0 then
  gitlab_issue_opts_tmpl['milestone_id'] = c.fetch('gitlab_milestoneid')
end
if c.fetch('gitlab_labels') != '' then
  gitlab_issue_opts_tmpl['labels'] = c.fetch('gitlab_labels')
end


### Define SQLs

sql_tickets = \
  'SELECT * FROM ost_all_descriptions
   ORDER BY created'

sql_comments = \
  'SELECT * FROM ost_comments
   WHERE thread_id = ?
   ORDER BY id'


### Set up clients

Gitlab.configure do |config|
  config.endpoint = c.fetch('gitlab_client_endpoint')
  config.private_token = c.fetch('gitlab_client_privatetoken')
end

glc = Gitlab.client()

myc = Mysql2::Client.new( \
  host: c.fetch('mysql_client_host') , \
  port: c.fetch('mysql_client_port') , \
  username: c.fetch('mysql_client_username') , \
  password: c.fetch('mysql_client_password') , \
  database: c.fetch('mysql_client_database') )


### Main

q_tickets = myc.prepare(sql_tickets)
r_tickets = q_tickets.execute()

q_comments = myc.prepare(sql_comments)

r_tickets.each do |t|
  puts
  print "INFO: Migrate ticket ID ", t['ticket_id'], ', subject "', t['subject'], '"'

  gitlab_issue_opts = gitlab_issue_opts_tmpl
  gitlab_issue_opts['description'] = t['description']

  mig_issue = \
    glc.create_issue( \
      gitlab_project , \
      t['subject'] , \
      gitlab_issue_opts )

  r_comments = q_comments.execute(t['thread_id'])

  r_comments.each do |comment|
    mig_comment = \
      glc.create_issue_note( \
        mig_issue.project_id, \
        mig_issue.iid, \
        comment['comment'] )
  end

end

