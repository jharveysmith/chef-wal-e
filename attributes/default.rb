
default[:wal_e][:packages] = [
  "python-setuptools",
  "python-dev",
  "lzop",
  "pv",
  "git",
  "postgresql-client",
  "libevent-dev",
  "daemontools"

]

default[:wal_e][:pips] = [
  "gevent",
  "argparse",
  "boto"
]

default[:wal_e][:git_version]         = "v0.6.5"

default[:wal_e][:env_dir]             = '/etc/wal-e'
default[:wal_e][:aws_access_key]      = nil
default[:wal_e][:aws_secret_key]      = nil
default[:wal_e][:s3_bucket]           = nil
default[:wal_e][:bkp_folder]          = node['hostname'] + '-pq-' + ( node['postgresql']['version'] || '-unknown' ).to_s

default[:wal_e][:base_backup][:minute]  = '0'
default[:wal_e][:base_backup][:hour]    = '0'
default[:wal_e][:base_backup][:day]     = '*'
default[:wal_e][:base_backup][:month]   = '*'
default[:wal_e][:base_backup][:weekday] = '1'

default[:wal_e][:user]                = 'postgres'
default[:wal_e][:group]               = 'postgres'
default[:wal_e][:pgdata_dir]          = node['postgresql']['config']['data_directory']
