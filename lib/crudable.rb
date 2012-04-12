module Crudable
  autoload :VERSION, "crudable/version"
  autoload :Filter, "crudable/filter"
  autoload :Model, "crudable/model"

  ::ActiveRecord::Base.class_eval{ include Model }
  ::ActionController::Base.class_eval{ include Filter }
end

