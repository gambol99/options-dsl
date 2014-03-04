#
# Author: Rohith 
# Date:   2014-02-26 22:17:43
# Last Modified by:   Rohith
#
# vim:ts=4:sw=4:et
#

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

command :up, 'used to bring up and virtual instance' do 
    input :host_name,
        :description    => 'the hostname of the box',
        :validation     => :hostname,
        :options        => :hostname,        
        :optional       => false

    input :schema,
        :description    => 'allows to to bring up multiple boxes based on a schema, see examples',
        :validation     => :schema,
        :options        => :schema,
        :optional       => true   

    input :number,
        :description    => 'used in combination with the schema; the number of boxes',
        :validation     => :integer,
        :options        => :number,
        :optional       => true

    input :box_name,
        :description    => 'the name of the vagrant box you wish to use',
        :defaults       => 'cento64',
        :validation     => :box_name,
        :options        => :box_name,
        :optional       => false

    input :ipaddress,
        :description    => 'allow boxes are dhcp unless you define an ipaddress here',
        :validation     => :ipaddress,
        :options        => :ipaddress,
        :optional       => true

    input :memory,
        :description    => 'the amount of memory (in mb) to assign to the instance',
        :defaults       => '512',
        :validation     => :integer,
        :options        => :memory,
        :optional       => false

    input :processors,
        :description    => 'the number of processors to assign to the instance',
        :defaults       => '1',
        :validation     => :integer,
        :options        => :processors,
        :optional       => false

    input :classes,
        :description    => 'assign a puppet class to this instance',
        :validation     => :puppet_class,
        :options        => :puppet_class,
        :optional       => true

    input :class_attribute,
        :description    => 'add a class attribute to the last class defined',
        :validation     => :puppet_attribute,
        :options        => :puppet_attribute,
        :optional       => true

    example 'whip up an single instance',
        'up -H test301-hsk'

    example 'bring up an instance with assigned puppet classifications',
        'up -H test301-hsk --class zookeeper --class collectd'

    example 'adding class paramemeter in the classifications of an instance',
        'up -H test301-hsk --class zookeeper --ca cluster_name=zoo'

end

command :destroy, 'bring down and destory the boxe' do 
    input :hostname,
        :description    => 'the hostname of the instance you wish to destroy',
        :validation     => :hostname,
        :options        => :hostname,
        :optional       => true

    input :hostname_regex,
        :description    => 'destroy the boxes based on this regex',
        :validation     => :regex,
        :options        => :regex,
        :optional       => true

    example 'destroy a virtual instance',
        'destory -H test301-hsk'

    example 'destory all the virtual instances of test',
        'destory -r ^test'        

end

command :ssh, 'use vagrant to ssh into the box' do 
    input :hostname,
        :description    => 'the hostname of the instance you wish to ssh into',
        :validation     => :hostname,
        :options        => :hostname,
        :optional       => false

    example 'ssh into in to a running instance',
        'ssh -H hostname [options]'

end

#command :list, 'retrieve information/status on the virtual instances' do 
#    usage 'list [options]'




#end

command :formation, 'bring up a complete formation of machines' do 
    input :formation,
        :description    => 'the full path to the formation file',
        :validation     => :filename,
        :options        => :formation,
        :optional       => false

    input :action,
        :description    => 'the action to perform on the formation, up, down, destroy',
        :validation     => :formation_action,
        :options        => :formation_action,
        :optional       => false

    input :formation_file,
        :description    => 'the full path to the formation file',
        :defaults       => 'puppet/formation.yaml',
        :validation     => :filename,
        :options        => :config,
        :optional       => false

    example 'bring up a formation for boxes',
        'formation -f formation -a up [-c formation_file.yaml]'

    example 'being down a formation of boxes',
        'formation -f formation -a down'

end

######### Options ########

option :action,
    :short  => '-a action',
    :long   => '--action action'

option :box_name,
    :short  => '-b box_name',
    :long   => '--box box_name'

option :config,
    :short  => '-c filename',
    :long   => '--config filename'

option :classification,
    :short  => '-C filename',
    :long   => '--classify filename'

option :formation,
    :short  => '-f filename',
    :long   => '--formation filename'

option :formation_action,
    :short  => '-a action',
    :long   => '--action action'

option :hostname,
    :short  => '-H hostname',
    :long   => '--hostname hostname'

option :ipaddress,
    :short  => '-i ipaddress',
    :long   => '--ip ipaddress'

option :memory,
    :short  => '-m memory',
    :long   => '--mem memory'

option :number,
    :short  => '-n number',
    :long   => '--number number'

option :processors,
    :short  => '-p number',
    :long   => '--processors number'

option :puppet_class,
    :short  => '-c class_name',
    :long   => '--class class_name'

option :puppet_attribute,
    :short  => '-a class_attribute',
    :long   => '--ca class_attribute'

option :regex,
    :short  => '-r regex',
    :long   => '--regex regex'

option :schema,
    :short  => '-s schema',
    :long   => '--schema schema'

option :vagrant,
    :short  => '-V vagrant_command',
    :long   => '--vagrant vagrant_command'

option :vbox_manage,
    :short  => '-M vbox_manage',
    :long   => '--vbox_manage vbox_manage'


######## Validations ########

validation :executable,
    :format     => :string,
    :regex      => /.*/,
    :proc       => Proc.new { |filename| 


    }

validation :filename,
    :format     => :string,
    :regex      => /.*/,
    :proc       => Proc.new { |filename| 

    }

validation :hostname,
    :format     => :string,
    :regex      => /^[[:alpha:]\-]{4,10}[0-9]{3}-[[:alnum:]]{2,5}$/

validation :formation_action,
    :format     => :string,
    :regex      => /^(up|down|destroy)$/

validation :schema,
    :format     => :string,
    :regex      => /.*/

validation :integer,
    :format     => :integer,
    :regex      => /^[0-9]+$/

validation :box_name,
    :format     => :string,
    :regex      => /^[[:alnum:]]+$/

validation :ipaddress,
    :format     => :string,
    :regex      => /^([0-9]{1,3}\.){3}[0-9]{1,2}$/

validation :puppet_class,
    :format     => :hash,
    :regex      => /^[[:alpha:]\:]+$/

validation :puppet_attribute,
    :format     => :string,
    :regex      => /.*/

validation :regex,
    :format     => :string,
    :regex      => /.*/
