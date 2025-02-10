# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # Ensures that rescued exception variables are named as expected.
      #
      # The `PreferredName` config option specifies the required name of the variable.
      # Its default is `e`, as referenced from `Naming/RescuedExceptionsVariableName`.
      #
      # @example PreferredName: e (default)
      #   # bad
      #   rescue_from MyException do |exception|
      #     # do something
      #   end
      #
      #   # good
      #   rescue_from MyException do |e|
      #     # do something
      #   end
      #
      #   # good
      #   rescue_from MyException do |_e|
      #     # do something
      #   end
      #
      # @example PreferredName: exception
      #   # bad
      #   rescue_from MyException do |e|
      #     # do something
      #   end
      #
      #   # good
      #   rescue_from MyException do |exception|
      #     # do something
      #   end
      #
      #   # good
      #   rescue_from MyException do |_exception|
      #     # do something
      #   end
      #
      class RescueFromExceptionsVariableName < Base
        include ConfigurableEnforcedStyle
        extend AutoCorrector

        MSG_LAMBDA = 'Use `(%<preferred>s)` instead of `(%<current>s)`.'
        MSG_BLOCK = 'Use `|%<preferred>s|` instead of `|%<current>s|`.'

        def_node_matcher :rescue_from_block_argument_variable?, <<~PATTERN
          (block (send nil? :rescue_from ...) (args (arg $_)) _)
        PATTERN

        def_node_matcher :rescue_from_with_lambda_variable?, <<~PATTERN
          (send nil? :rescue_from ... (hash <(pair (sym :with) (block _ (args (arg $_)) _))>))
        PATTERN

        def_node_matcher :rescue_from_with_block_variable?, <<~PATTERN
          (send nil? :rescue_from ... {(block _ (args (arg $_)) _) (splat (block _ (args (arg $_)) _))})
        PATTERN

        def on_block(node)
          rescue_from_block_argument_variable?(node) do |arg_name|
            check_offense(node.first_argument, arg_name)
          end
        end
        alias on_numblock on_block

        def on_send(node)
          check_rescue_from_variable(node, :rescue_from_with_lambda_variable?)
          check_rescue_from_variable(node, :rescue_from_with_block_variable?)
        end

        private

        def check_rescue_from_variable(node, matcher)
          send(matcher, node) do |arg_name|
            lambda_arg = node.each_descendant(:args).first&.children&.first
            check_offense(lambda_arg, arg_name) if lambda_arg
          end
        end

        def check_offense(arg_node, arg_name)
          preferred = preferred_name(arg_name)
          return if arg_name.to_s == preferred

          range = arg_node.source_range.with(
            begin_pos: arg_node.source_range.begin_pos - 1,
            end_pos: arg_node.source_range.end_pos + 1
          )

          message = arg_node.parent.parent&.lambda? ? MSG_LAMBDA : MSG_BLOCK

          add_offense(range, message: format(message, preferred: preferred, current: arg_name)) do |corrector|
            corrector.replace(range, arg_node.parent.parent&.lambda? ? "(#{preferred})" : "|#{preferred}|")

            parent_block = arg_node.ancestors.find(&:block_type?)
            return unless parent_block

            parent_block.each_descendant(:lvar).each do |lvar_node|
              corrector.replace(lvar_node, preferred) if lvar_node.children.first == arg_name
            end
          end
        end

        def preferred_name(name)
          config_name = cop_config.fetch('PreferredName', 'e')
          name.start_with?('_') ? "_#{config_name}" : config_name
        end
      end
    end
  end
end
