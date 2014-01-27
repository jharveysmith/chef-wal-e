#
# Cookbook Name:: wal-e
# Recipe:: default

missing_attrs = %w{
  aws_access_key
  aws_secret_key
  s3_bucket
}.select do |attr|
  node[:wal_e][attr].nil?
end.map { |attr| "node[:wal_e][:#{attr}]" }

if !missing_attrs.empty?
  Chef::Application.fatal!([
      "You must set #{missing_attrs.join(', ')}.",
    ].join(' '))
end

#install packages
node[:wal_e][:packages].each do |pkg|
  package pkg
end

#install python modules with pip unless overriden
unless node[:wal_e][:pips].nil?
  include_recipe "python::pip"
  node[:wal_e][:pips].each do |pp|
    python_pip "gevent"
  end
end

code_path = "#{Chef::Config[:file_cache_path]}/wal-e"

bash "install_wal_e" do
  cwd code_path
  code <<-EOH
    /usr/bin/python ./setup.py install
  EOH
  action :nothing
end

git code_path do
  repository "https://github.com/wal-e/wal-e.git"
  revision "v0.6.5"
  notifies :run, "bash[install_wal_e]"
end

directory node[:wal_e][:env_dir] do
  user    node[:wal_e][:user]
  group   node[:wal_e][:group]
  mode    "0550"
end

vars = {'AWS_ACCESS_KEY_ID'     => node[:wal_e][:aws_access_key],
        'AWS_SECRET_ACCESS_KEY' => node[:wal_e][:aws_secret_key],
        'WALE_S3_PREFIX'        => "s3://#{node[:wal_e][:s3_bucket]}/#{node[:wal_e][:bkp_folder]}"
}

vars.each do |key, value|
  file "#{node[:wal_e][:env_dir]}/#{key}" do
    content value
    user    node[:wal_e][:user]
    group   node[:wal_e][:group]
    mode    "0440"
  end
end

cron "wal_e_base_backup" do
  user node[:wal_e][:user]
  command "/usr/bin/envdir #{node[:wal_e][:env_dir]} /usr/local/bin/wal-e backup-push #{node[:wal_e][:pgdata_dir]}"

  minute node[:wal_e][:base_backup][:minute]
  hour node[:wal_e][:base_backup][:hour]
  day node[:wal_e][:base_backup][:day]
  month node[:wal_e][:base_backup][:month]
  weekday node[:wal_e][:base_backup][:weekday]
end
