################################################################################
# (c) Copyright 2007-2012 Alces Software Ltd & Stephen F Norledge.             #
#                                                                              #
# Symphony - Operating System Content Deployment Framework                     #
#                                                                              #
# This file/package is part of Symphony                                        #
#                                                                              #
# Symphony is free software: you can redistribute it and/or modify it under    #
# the terms of the GNU Affero General Public License as published by the Free  #
# Software Foundation, either version 3 of the License, or (at your option)    #
# any later version.                                                           #
#                                                                              #
# Symphony is distributed in the hope that it will be useful, but WITHOUT      #
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or        #
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License #
# for more details.                                                            #
#                                                                              #
# You should have received a copy of the GNU Affero General Public License     #
# along with Symphony.  If not, see <http://www.gnu.org/licenses/>.            #
#                                                                              #
# For more information on the Symphony Toolkit, please visit:                  #
# https://github.com/alces-software/symphony                                       #
#                                                                              #
################################################################################
require 'alces/packager/config'
require 'dm-core'
require 'dm-migrations'

module Alces
  module Packager
    module Dao
      class << self
        def initialize!(opts = {})
          DataMapper.setup(:default, "sqlite://#{File.expand_path(File.join(Config.dbroot,'package.db'))}")
          if Config.config[:global_dbroot]
            DataMapper.setup(:global, "sqlite://#{File.expand_path(File.join(Config.global_dbroot,'package.db'))}")
          end
        end

        def finalize!
          DataMapper.finalize
          DataMapper.auto_upgrade!
        end
      end
    end
    Dao.initialize!
  end
end
