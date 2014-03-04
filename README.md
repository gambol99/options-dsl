Options DSL
===========

Notes: Still needs some work :-)

OptionsDSL is a library for defining command line options (albeit it could be used for other argument processing). The options, including global flags / switches and validation code can also be used to for subcommand; i.e. ./scipt.rb <command> [options]

The DSL can been loaded from a single file or multiple files from a directory;  The OptionsDSL class requires the following

    config = {
        :directory  => '/my/directory/of/rules',       # the full path to the directory,
        :extensions => '*.ddl'                         # the regex to determine which file/s to read
        :log_level  => [nil,:info|:warn|:debug]        # the logging level to employ
    }
    # the second argument can be used to pass some default options
    dsl = OptionsDSL::new config, options | nil

Below is an example of the DSL language. Note, :global is a special command and effectly to used to describe all non subcommand options.

    command :global, 'global and misc options' do 
        input :vagrant,
            :description    => 'the location of the vagrant executable',
            :defaults       => 'vagrant',
            :validation     => :executable,
            :options        => :vagrant,
            :optional       => false
    
        input :vbox_manage,
            :description    => 'the location of the virtualbox manager tool',
            :defaults       => 'VBoxManage',
            :validation     => :executable,
            :options        => :vbox_manage,
            :optional       => false
    
        input :classification,
            :description    => 'the location of the puppet classification file',
            :defaults       => 'puppet/classification.yaml',
            :validation     => :filename,
            :options        => :classification,
            :optional       => false
    end
    
So to produce the following 
    
    ./script subcommand1 -H hostname -d domain

The dsl would resemble
    
    command :subcommand1, 'global and misc options' do 
        input :hostname,
            :description    => 'some description',
            :validation     => :string,
            :options        => :hostname,
            :optional       => false
    
        input :domain,
            :description    => 'the domain',
            :validation     => :domain,
            :options        => :domain,
            :optional       => false
    end
    
    options :hostname,
        :short  => '-H hostname',
        :long   => '--hostname hostname'
    
    options :domain,
        :short  => '-d domain',
        :long   => '--domain domain'
    
    validation :hostname,
        :format     => :string,
        :regex      => /^[[:alpha:]\-]{,10}[0-9]{3}-[[:alnum:]]{2,5}$/ 
    
    validation :domain
        :format     => :string,
        :regex      => /.*/
        

    





