# Copyright 2011-2013 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License"). You
# may not use this file except in compliance with the License. A copy of
# the License is located at
#
#     http://aws.amazon.com/apache2.0/
#
# or in the "license" file accompanying this file. This file is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF
# ANY KIND, either express or implied. See the License for the specific
# language governing permissions and limitations under the License.

module AWS
  module Core
    module XML

      # @api private
      module FrameStack

        # @param [Hash] rules A hash of parser rules.  These
        #   rules are typically generated by an {XML::Grammar}.
        def initialize rules
          @frame = RootFrame.new(rules)
        end

        def sax_parse xml
          raise NotImplementedError
        end
        protected :sax_parse

        # Parses the xml string and returns a hash with the resutls.
        # @param [String] xml
        # @return [Hash]
        def parse xml
          sax_parse(xml)
          @frame.value
        end

        # Increase the frame stack level by one.
        # @param [String] element_name The name of the xml opening tag.
        # @param [Hash] attributes A hash of xml element attributes.
        # @return [nil]
        def start_element element_name, attributes = {}
          @frame = @frame.build_child_frame(element_name)
          self.attributes(attributes)
          nil
        end

        # Increase the frame stack level by one by treating
        # xml element attributes as nested elements.
        # @param [Hash] attributes A hash of attributes names to values.
        # @return [nil]
        def attributes attributes
          attributes.each_pair do |attr_name, attr_value|
            attr_frame = @frame.build_child_frame(attr_name)
            attr_frame.add_text(attr_value)
            @frame.consume_child_frame(attr_frame)
          end
          nil
        end

        # Pops the top frame off the stack.  When closing frames
        # their final value is computed.
        # @overload end_element
        # @return [nil]
        def end_element *ignored
          parent = @frame.parent_frame
          child = @frame
          parent.consume_child_frame(child)
          @frame = @frame.parent_frame
          nil
        end

        # Adds text to the current frame.  Frames that only contain
        # text and no child elements are leaf nodes and have
        # raw string values.
        def set_text text
          @frame.add_text(text) if @frame
        end

      end
    end
  end
end
