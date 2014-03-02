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

######### Options ########

options :action,
    :short  => '-a action',
    :long   => '--action action'

options :hostname,
    :short  => '-H hostname',
    :long   => '--hostname hostname'

options :regex,
    :short  => '-r regex',
    :long   => '--regex regex'

options :schema,
    :short  => '-s schema',
    :long   => '--schema schema'

options :number,
    :short  => '-n number',
    :long   => '--number number'

options :box_name,
    :short  => '-b box_name',
    :long   => '--box box_name'

options :ipaddress,
    :short  => '-i ipaddress',
    :long   => '--ip ipaddress'

options :memory,
    :short  => '-m memory',
    :long   => '--mem memory'

options :processors,
    :short  => '-p number',
    :long   => '--processors number'

options :class,
    :short  => '-c class_name',
    :long   => '--class class_name'

options :class_attribute,
    :short  => '-a class_attribute',
    :long   => '--ca class_attribute'

options :formation,
    :short  => '-f filename',
    :long   => '--formation filename'

options :config,
    :short  => '-c filename',
    :long   => '--config filename'


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
    :regex      => /^[[:alpha:]\-]{,10}[0-9]{3}-[[:alnum:]]{2,5}$/

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
    :format     => :string,
    :regex      => /^[[:alpha:]\:]+$/

validation :puppet_attribute,
    :format     => :string,
    :regex      => /.*/

