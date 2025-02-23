# frozen_string_literal: true

require 'test_helper'

describe ActiveStorageValidations::Matchers::ContentTypeValidatorMatcher do
  include MatcherHelpers

  let(:matcher) { ActiveStorageValidations::Matchers::ContentTypeValidatorMatcher.new(model_attribute) }
  let(:klass) { ContentType::Matcher }

  describe '#allowing' do
    describe 'one' do
      let(:model_attribute) { :allowing_one }
      let(:allowed_type) { 'image/png' }

      describe 'when provided with the exact allowed type' do
        subject { matcher.allowing(allowed_type) }

        it { is_expected_to_match_for(klass) }
      end

      describe 'when provided with something that is not a valid type' do
        subject { matcher.allowing(not_valid_type) }

        let(:not_valid_type) { 'not_valid' }

        it { is_expected_not_to_match_for(klass) }
      end
    end

    describe 'several' do
      let(:model_attribute) { :allowing_several }
      let(:allowed_types) { ['image/png', 'image/gif'] }
      let(:not_allowed_types) { ['video/mkv', 'file/pdf'] }

      describe 'when provided with the exact allowed types' do
        subject { matcher.allowing(*allowed_types) }

        it { is_expected_to_match_for(klass) }
      end

      describe 'when provided with only allowed types but not all types' do
        subject { matcher.allowing(allowed_types.sample) }

        it { is_expected_to_match_for(klass) }
      end

      describe 'when provided with allowed and not allowed types' do
        subject { matcher.allowing(allowed_types.sample, not_allowed_types.sample) }

        it { is_expected_not_to_match_for(klass) }
      end

      describe 'when provided with only not allowed types' do
        subject { matcher.allowing(*not_allowed_types) }

        it { is_expected_not_to_match_for(klass) }
      end

      describe 'when provided with something that is not a valid type' do
        subject { matcher.allowing(not_valid_type) }

        let(:not_valid_type) { 'not_valid' }

        it { is_expected_not_to_match_for(klass) }
      end
    end

    describe 'several through regex' do
      let(:model_attribute) { :allowing_several_through_regex }
      let(:some_allowed_types) { ['image/png', 'image/gif'] }
      let(:not_allowed_types) { ['video/mkv', 'file/pdf'] }

      describe 'when provided with only allowed types but not all types' do
        subject { matcher.allowing(*some_allowed_types) }

        it { is_expected_to_match_for(klass) }
      end

      describe 'when provided with allowed and not allowed types' do
        subject { matcher.allowing(some_allowed_types.sample, not_allowed_types.sample) }

        it { is_expected_not_to_match_for(klass) }
      end

      describe 'when provided with only not allowed types' do
        subject { matcher.allowing(*not_allowed_types) }

        it { is_expected_not_to_match_for(klass) }
      end

      describe 'when provided with something that is not a valid type' do
        subject { matcher.allowing(not_valid_type) }

        let(:not_valid_type) { 'not_valid' }

        it { is_expected_not_to_match_for(klass) }
      end
    end
  end

  describe '#rejecting' do
    let(:model_attribute) { :allowing_one }
    let(:allowed_type) { 'image/png' }

    describe 'when provided with the exact allowed type' do
      subject { matcher.rejecting(allowed_type) }

      it { is_expected_not_to_match_for(klass) }
    end

    describe 'when provided with any type but the allowed type' do
      subject { matcher.rejecting(any_type) }

      let(:any_type) { 'video/mkv' }

      it { is_expected_to_match_for(klass) }
    end

    describe 'when provided with any types but the allowed type' do
      subject { matcher.rejecting(*any_types) }

      let(:any_types) { ['video/mkv', 'image/gif'] }

      it { is_expected_to_match_for(klass) }
    end

    describe 'when provided with any types and the allowed type' do
      subject { matcher.rejecting(*types) }

      let(:any_types) { ['video/mkv', 'image/gif'] }
      let(:types) { any_types + [allowed_type] }

      it { is_expected_not_to_match_for(klass) }
    end

    describe 'when provided with something that is not a valid type' do
      subject { matcher.rejecting(not_valid_type) }

      let(:not_valid_type) { 'not_valid' }

      it { is_expected_to_match_for(klass) }
    end
  end

  describe '#with_message' do
    let(:model_attribute) { :with_message }

    describe 'when provided with the allowed content type' do
      before { matcher.allowing('image/png') }

      describe 'and with the message specified in the model validations' do
        subject { matcher.with_message('Not authorized file type.') }

        it { is_expected_to_match_for(klass) }
      end

      describe 'and with a different message than the one specified in the model validations' do
        subject { matcher.with_message('<wrong message>') }

        it { is_expected_not_to_match_for(klass) }
      end

      describe 'but without the #with_message matcher method' do
        subject { matcher }

        it { is_expected_to_match_for(klass) }
      end
    end
  end

  describe 'Combinations' do
    describe '#allowing + #with_message' do
      let(:model_attribute) { :allowing_one_with_message }
      let(:allowed_type) { 'file/pdf' }

      describe 'when provided with the exact allowed type' do
        describe 'and when provided with the message specified in the model validations' do
          subject do
            matcher.allowing(allowed_type)
            matcher.with_message('Not authorized file type.')
          end

          it { is_expected_to_match_for(klass) }
        end
      end
    end

    describe '#rejecting + #with_message' do
      let(:model_attribute) { :allowing_one_with_message }
      let(:not_allowed_type) { 'video/mkv' }

      describe 'when provided with a not allowed type' do
        describe 'and when provided with the message specified in the model validations' do
          subject do
            matcher.rejecting(not_allowed_type)
            matcher.with_message('Not authorized file type.')
          end

          it { is_expected_to_match_for(klass) }
        end
      end
    end

    describe '#allowing + #rejecting' do
      let(:model_attribute) { :allowing_one }
      let(:allowed_type) { 'image/png' }
      let(:not_allowed_type) { 'video/mkv' }

      describe 'when provided with the exact allowed type' do
        describe 'and when provided with a not allowed type specified in the model validations' do
          subject do
            matcher.allowing(allowed_type)
            matcher.rejecting(not_allowed_type)
          end

          it { is_expected_to_match_for(klass) }
        end
      end
    end

    describe '#allowing + #rejecting + #with_message' do
      let(:model_attribute) { :allowing_one_with_message }
      let(:allowed_type) { 'file/pdf' }
      let(:not_allowed_type) { 'video/mkv' }

      describe 'when provided with the exact allowed type' do
        describe 'and when provided with a not allowed type' do
          describe 'and when provided with the message specified in the model validations' do
            subject do
              matcher.allowing(allowed_type)
              matcher.rejecting(not_allowed_type)
              matcher.with_message('Not authorized file type.')
            end

            it { is_expected_to_match_for(klass) }
          end
        end
      end
    end
  end

  describe 'when the passed model attribute' do
    describe 'does not exist' do
      subject { matcher }

      let(:model_attribute) { :not_present_in_model }

      it { is_expected_not_to_match_for(klass) }
    end

    describe 'has a custom validation error message' do
      describe 'but the matcher is not provided with a #with_message' do
        subject { matcher }

        let(:model_attribute) { :with_message }

        it { is_expected_to_match_for(klass) }
      end
    end
  end

  describe 'when the matcher is provided with an instance' do
    subject { matcher.with_message('Not authorized file type.') }

    let(:model_attribute) { :with_message }
    let(:instance) { klass.new }

    it { is_expected_to_match_for(instance) }
  end
end
