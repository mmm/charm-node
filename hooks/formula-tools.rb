
require 'erb'


module Ensemble

  # mimic the exsting cli api

  module Relation
    def relation-list
      `relation-list` || []
    end

    def relation-get(unit_name,attribute='-')
      `relation-get --format json #{attribute} #{unit_name}` || ""
    end

    def relation-set(*args)
    end
  end
end
use Ensemble::Relation

module Ensemble
  module Config
    def config-get(*args)
      ""
    end

    def config-set(*args)
    end
  end
end
use Ensemble::Config

def log(msg) do
  `ensemble-log #{msg}`
end


def relations
  relation-list.each do |service|
    hostname=`relation-get --format json#{service} hostname`
    port=`relation-get #{service} port`
  end
end

def relation_info
  <<-EOS
  #{ENV['ENSEMBLE_REMOTE_UNIT']} modified its settings...
  Relation settings:
    #{`relation-get --format json`}
  Relation members:
    #{`relation-list`}
  EOS
end

`relation-list`.each do |service|
  hostname=`relation-get #{service} hostname`
  port=`relation-get #{service} port`
end


def template_file(filename) do
  template_path = File.join('./hooks/templates',filename)
  ERB.new(File.read(template_path)).result(binding)
end

%w{ start stop restart }.each do |action|
  define_method "#{action}_service" do |service_name|
    log "#{action.capitalize}ing #{service_name}"
    `service #{service_name} #{action}`
  end
end

