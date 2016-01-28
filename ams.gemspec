# coding: utf-8

Gem::Specification.new do |spec|
  spec.name          = 'AMS'
  spec.version       = File.read('VERSION')
  spec.authors       = ['Benjamin Fleischer']
  spec.email         = ['dev@benjaminfleischer.com']
  spec.summary       = 'Reserves the AMS namespace for ActiveModelSerializers'
  spec.description   = 'AMS is placeholder gem for the AMS namespace, used by the active_model_serializers gem.'
  spec.post_install_message = <<~EOF
    #{'*' * 8}
    #{spec.description}
    #{'*' * 8}
  EOF
  spec.homepage      = 'https://github.com/bf4/ams'
  spec.license       = 'MIT'

  spec.metadata = {
    'homepage_uri'      => spec.homepage,
    # 'wiki_uri'          => nil,
    # 'documentation_uri' => nil,
    # 'mailing_list_uri'  => nil,
    'source_code_uri'   => spec.homepage,
    'bug_tracker_uri'   => spec.homepage + '/issues'
  }

  spec.files         = []
  spec.test_files    = []
  spec.require_paths = ['lib']
  spec.executables   = []
  spec.extensions    = []
end
