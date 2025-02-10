# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::RescueFromExceptionsVariableName, :config do
  it 'does not register an offense without variable' do
    expect_no_offenses(<<~RUBY)
      rescue_from MyException do
        # do something
      end
    RUBY
  end

  context 'with default config' do
    context 'when using default variable' do
      it 'does not register an offense with a single rescued exception' do
        expect_no_offenses(<<~RUBY)
          rescue_from MyException do |e|
            # do something
          end
        RUBY
      end

      it 'does not register an offense with multiple rescued exceptions' do
        expect_no_offenses(<<~RUBY)
          rescue_from MyException, MyOtherException do |e|
            # do something
          end
        RUBY
      end

      it 'does not register an offense with underscored prefix variable' do
        expect_no_offenses(<<~RUBY)
          rescue_from MyException do |_e|
            # do something
          end
        RUBY
      end

      it 'does not register an offense using splat operator' do
        expect_no_offenses(<<~RUBY)
          rescue_from *handled do |e|
            # do something
          end
        RUBY
      end

      it 'does not register an offense when using the correct variable in a lambda' do
        expect_no_offenses(<<~RUBY)
          rescue_from MyException, with: ->(e) { puts e.message }
        RUBY
      end

      it 'does not register an offense when using the underscored variable in a lambda' do
        expect_no_offenses(<<~RUBY)
          rescue_from MyException, with: ->(_e) { do_something }
        RUBY
      end
    end

    context 'when using another variable' do
      context 'when using a multiline block' do
        it 'registers an offense with a single rescued exception' do
          expect_offense(<<~RUBY)
            rescue_from MyException do |exception|
                                       ^^^^^^^^^^^ Use `|e|` instead of `|exception|`.
              # do something
            end
          RUBY

          expect_correction(<<~RUBY)
            rescue_from MyException do |e|
              # do something
            end
          RUBY
        end

        it 'registers an offense with multiple rescued exceptions' do
          expect_offense(<<~RUBY)
            rescue_from MyException, MyOtherException do |exception|
                                                         ^^^^^^^^^^^ Use `|e|` instead of `|exception|`.
              # do something
            end
          RUBY

          expect_correction(<<~RUBY)
            rescue_from MyException, MyOtherException do |e|
              # do something
            end
          RUBY
        end

        it 'registers an offense with underscored prefix variable' do
          expect_offense(<<~RUBY)
            rescue_from MyException do |_exception|
                                       ^^^^^^^^^^^^ Use `|_e|` instead of `|_exception|`.
              # do something
            end
          RUBY

          expect_correction(<<~RUBY)
            rescue_from MyException do |_e|
              # do something
            end
          RUBY
        end

        it 'registers an offense using splat operator' do
          expect_offense(<<~RUBY)
            rescue_from *handled do |exception|
                                    ^^^^^^^^^^^ Use `|e|` instead of `|exception|`.
              # do something
            end
          RUBY

          expect_correction(<<~RUBY)
            rescue_from *handled do |e|
              # do something
            end
          RUBY
        end

        it 'does not register an offense with multiple arguments' do
          expect_no_offenses(<<~RUBY)
            rescue_from MyException do |exception, context|
              # do something
            end
          RUBY
        end
      end

      context 'when using a single-line block' do
        it 'registers an offense with a single rescued exception' do
          expect_offense(<<~RUBY)
            rescue_from MyException { |exception| do_something(exception) }
                                      ^^^^^^^^^^^ Use `|e|` instead of `|exception|`.
          RUBY

          expect_correction(<<~RUBY)
            rescue_from MyException { |e| do_something(e) }
          RUBY
        end

        it 'registers an offense with multiple rescued exceptions' do
          expect_offense(<<~RUBY)
            rescue_from MyException, MyOtherException { |exception| do_something(exception) }
                                                        ^^^^^^^^^^^ Use `|e|` instead of `|exception|`.
          RUBY

          expect_correction(<<~RUBY)
            rescue_from MyException, MyOtherException { |e| do_something(e) }
          RUBY
        end

        it 'registers an offense with underscored prefix variable' do
          expect_offense(<<~RUBY)
            rescue_from MyException { |_exception| do_something(exception) }
                                      ^^^^^^^^^^^^ Use `|_e|` instead of `|_exception|`.
          RUBY

          expect_correction(<<~RUBY)
            rescue_from MyException { |_e| do_something(exception) }
          RUBY
        end

        it 'registers an offense using splat operator' do
          expect_offense(<<~RUBY)
            rescue_from *handled { |_exception| do_something(exception) }
                                   ^^^^^^^^^^^^ Use `|_e|` instead of `|_exception|`.
          RUBY

          expect_correction(<<~RUBY)
            rescue_from *handled { |_e| do_something(exception) }
          RUBY
        end

        it 'does not register an offense with multiple arguments' do
          expect_no_offenses(<<~RUBY)
            rescue_from MyException { |exception, context| do_something(exception, context) }
          RUBY
        end
      end

      context 'when using a multiline lambda' do
        it 'registers an offense with a single rescued exception' do
          expect_offense(<<~RUBY)
            rescue_from MyException, with: ->(exception) do
                                             ^^^^^^^^^^^ Use `(e)` instead of `(exception)`.
              puts exception.message
            end
          RUBY

          expect_correction(<<~RUBY)
            rescue_from MyException, with: ->(e) do
              puts e.message
            end
          RUBY
        end

        it 'registers an offense with multiple rescued exceptions' do
          expect_offense(<<~RUBY)
            rescue_from MyException, MyOtherException, with: ->(exception) do
                                                               ^^^^^^^^^^^ Use `(e)` instead of `(exception)`.
              puts exception.message
            end
          RUBY

          expect_correction(<<~RUBY)
            rescue_from MyException, MyOtherException, with: ->(e) do
              puts e.message
            end
          RUBY
        end

        it 'registers an offense with underscored prefix variable' do
          expect_offense(<<~RUBY)
            rescue_from MyException, with: ->(_exception) do
                                             ^^^^^^^^^^^^ Use `(_e)` instead of `(_exception)`.
              puts _exception.message
            end
          RUBY

          expect_correction(<<~RUBY)
            rescue_from MyException, with: ->(_e) do
              puts _e.message
            end
          RUBY
        end

        it 'registers an offense using splat operator' do
          expect_offense(<<~RUBY)
            rescue_from *handled, with: ->(exception) do
                                          ^^^^^^^^^^^ Use `(e)` instead of `(exception)`.
              puts exception.message
            end
          RUBY

          expect_correction(<<~RUBY)
            rescue_from *handled, with: ->(e) do
              puts e.message
            end
          RUBY
        end

        it 'does not register an offense with multiple arguments' do
          expect_no_offenses(<<~RUBY)
            rescue_from MyException, with: ->(exception, context) do
              puts [exception.message, context.message]
            end
          RUBY
        end
      end

      context 'when using a single-line lambda' do
        it 'registers an offense with a single rescued exception' do
          expect_offense(<<~RUBY)
            rescue_from MyException, with: ->(exception) { puts exception.message }
                                             ^^^^^^^^^^^ Use `(e)` instead of `(exception)`.
          RUBY

          expect_correction(<<~RUBY)
            rescue_from MyException, with: ->(e) { puts e.message }
          RUBY
        end

        it 'registers an offense with multiple rescued exceptions' do
          expect_offense(<<~RUBY)
            rescue_from MyException, MyOtherException, with: ->(exception) { puts exception.message }
                                                               ^^^^^^^^^^^ Use `(e)` instead of `(exception)`.
          RUBY

          expect_correction(<<~RUBY)
            rescue_from MyException, MyOtherException, with: ->(e) { puts e.message }
          RUBY
        end

        it 'registers an offense with underscored prefix variable' do
          expect_offense(<<~RUBY)
            rescue_from MyException, with: ->(_exception) { puts _exception.message }
                                             ^^^^^^^^^^^^ Use `(_e)` instead of `(_exception)`.
          RUBY

          expect_correction(<<~RUBY)
            rescue_from MyException, with: ->(_e) { puts _e.message }
          RUBY
        end

        it 'registers an offense using splat operator' do
          expect_offense(<<~RUBY)
            rescue_from *handled, with: ->(exception) { puts exception.message }
                                          ^^^^^^^^^^^ Use `(e)` instead of `(exception)`.
          RUBY

          expect_correction(<<~RUBY)
            rescue_from *handled, with: ->(e) { puts e.message }
          RUBY
        end

        it 'does not register an offense with multiple arguments' do
          expect_no_offenses(<<~RUBY)
            rescue_from MyException, with: ->(exception, context) { puts [exception.message, context.message] }
          RUBY
        end
      end
    end
  end

  context 'with the `PreferredName` setup' do
    let(:cop_config) do
      {
        'PreferredName' => 'exception'
      }
    end

    it 'does not register an offense when using the preferred name' do
      expect_no_offenses(<<~RUBY)
        rescue_from MyException do |exception|
          # do something
        end
      RUBY
    end

    it 'does not register an offense when using the preferred name withmultiple rescued exceptions' do
      expect_no_offenses(<<~RUBY)
        rescue_from MyException, MyOtherException do |exception|
          # do something
        end
      RUBY
    end

    it 'registers an offense when using another name' do
      expect_offense(<<~RUBY)
        rescue_from MyException do |e|
                                   ^^^ Use `|exception|` instead of `|e|`.
          # do something
        end
      RUBY

      expect_correction(<<~RUBY)
        rescue_from MyException do |exception|
          # do something
        end
      RUBY
    end

    it 'registers an offense with underscored prefix variable' do
      expect_offense(<<~RUBY)
        rescue_from MyException do |_e|
                                   ^^^^ Use `|_exception|` instead of `|_e|`.
          # do something
        end
      RUBY

      expect_correction(<<~RUBY)
        rescue_from MyException do |_exception|
          # do something
        end
      RUBY
    end
  end
end
