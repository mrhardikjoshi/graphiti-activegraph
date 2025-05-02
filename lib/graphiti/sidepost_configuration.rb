module Graphiti
  module SidepostConfiguration
    extend ActiveSupport::Concern

    included do
      attr_accessor :allow_sidepost
    end
  end
end
