# Corrige um bug real da gem rails_age — ver lib/apache_age/path_edge_label_fix.rb
require "apache_age/path_edge_label_fix"
ApacheAge::Path.singleton_class.prepend(ApacheAge::PathEdgeLabelFix)
