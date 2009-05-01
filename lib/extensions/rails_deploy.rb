=begin rdoc
  Deploy a rails application using chef_deploy
  
  Usage:
      has_rails_deploy "app_name" do
        dir "/var/www"
        repo "git://github.com/auser/paparazzi.git"
        user "www-data"
        database_yml /path/to/database.yml # or a string
      end
    
    Sets up the filesystem structure (similar to capistrano deploy) and uses ezra's
    chef-deploy to deploy the application
=end
module PoolParty
  class Rails
    
    plugin :rails_deploy do
      
      default_options(
        :dir => "/var/www",
        :owner => "www-data"
      )
      
      def loaded(o={}, &block)
        raise "You must include the directory to deploy the rails app" unless dir?
        raise "You must include the repo to deploy the rails app" unless repo?
        
        has_package "git-core"
        has_directory dir
        has_directory release_directory
        has_directory "#{release_directory}/shared", :owner => owner
        
        %w(config pids log).each do |d|
          has_directory "#{release_directory}/shared/#{d}", :owner => owner
        end
        
        has_file "#{release_directory}/shared/config/database.yml", :owner => owner do
          content ::File.file?(database_yml) ? open(database_yml).read : database_yml
        end
        
        # Should these be here?
        has_chef_recipe "apache2"
        has_chef_recipe "apache2::mod_rails"
        
        dopts = options.choose {|k,v| [:repo, :user].include?(k)}
        has_chef_deploy dopts.merge(:name => "#{release_directory}")
        
      end
      
      def release_directory
        "#{dir}/#{name}"
      end
      
    end
  end
end