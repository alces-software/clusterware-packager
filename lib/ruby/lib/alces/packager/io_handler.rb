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
module Alces
  module Packager
    module IoHandler
      class << self
        PRIM = [64,136,184]
        SEC1 = [77,91,194]
        SEC2 = [255,206,78]
        COMP = [255,177,78]

        include Alces::Tools::Logging

        def utter(msg, &block)
          info(msg, &block)
          say(msg)
        end

        def say(msg)
          $terminal.say(msg)
        end

        def title(msg, &block)
          info(msg, &block)
          say("\n > #{msg.bright.color(:blue)}")
        end

        def warning(msg, &block)
          warn(msg, &block)
          say("#{"WARNING!".color(:yellow)} #{msg}")
        end

        def doing(msg, width = 12, &block)
          info(msg, &block)
          say(sprintf("    #{"%#{width}s".color(:cyan)} ... ",msg))
        end

        def confirm(msg, &block)
          info("Asking for confirmation for: '#{msg}'", &block)
          say(msg)
          $terminal.agree("\nProceed (Y/N)? ")
        rescue Interrupt
          say "\nRequest cancelled by user."
          false
        end

        def tty?
          Sickill::Rainbow.enabled
        end

        def colored_path(p)
          case p
          when Metadata
            "#{p.repo.name.color(*SEC1)}/#{p.type.color(:magenta)}/#{p.name.color(*COMP)}".tap do |s|
              s << "/#{p.version.color(*PRIM)}" unless p.version.blank?
            end
          when Package
            "#{p.type.color(:magenta)}/#{p.name.color(*COMP)}/#{p.version.color(*PRIM)}".tap do |s|
              s << "/#{p.tag.color(*SEC1)}" unless p.tag.blank?
            end
          when String
            parts = p.split('/')
            "#{parts[0].color(:magenta)}".tap do |s|
              if parts.length > 1
                s << '/' << parts[1].color(*COMP)
              end
              if parts.length > 2
                s << '/' << parts[2].color(*PRIM)
              end
              if parts.length > 3
                3.upto(parts.length-1) do |n|
                  s << '/' << parts[n].color(*SEC1)
                end
              end
            end
          else
            p
          end
        end

        def with_spinner(&block)
          if !tty?
            block.call
          else
            begin
              print ' '
              spinner = Thread.new do
                spin = '|/-\\'
                i = 0
                loop do
                  print "\b#{spin[i]}"
                  sleep 0.2
                  i = 0 if (i += 1) == 4
                end
              end
              block.call
            ensure
              spinner.kill
              print "\b \b"
            end
          end
        end
      end
    end
  end
end
