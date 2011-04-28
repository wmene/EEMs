require 'dor/download_job'

module Sulair
  WORKSPACE_DIR = File.join(RAILS_ROOT, 'workspace')
  AUTHORIZED_EEMS_PRIVGROUP = 'some:group'
end

unless(File.exists?(Sulair::WORKSPACE_DIR))
  FileUtils.mkdir(Sulair::WORKSPACE_DIR)
  FileUtils.ln_s(Sulair::WORKSPACE_DIR, File.join(RAILS_ROOT, 'public', 'workspace'))
end

unless(File.exists?(File.join(RAILS_ROOT, 'tmp')))
  FileUtils.mkdir(File.join(RAILS_ROOT, 'tmp'))
end