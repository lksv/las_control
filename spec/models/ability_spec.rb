require 'rails_helper'

RSpec.describe Ability, type: :model do
  let(:user) { FactoryGirl.build(:user) }
  let(:subject) { Ability.new(user) }

  context 'public access' do

    let(:lau) { FactoryGirl.create(:local_administration_unit) }
    let(:unpublished_document) do
      document = Document.new(published: false, local_administration_unit: lau)
      document.save!(validate: false)
      document
    end
    let(:published_document) do
      document = Document.new(published: true, local_administration_unit: lau)
      document.save!(validate: false)
      document
    end
    let(:expired_ppi_document) do
      document = Document.new(
        published: true,
        local_administration_unit: lau,
        ppi_public_until: Time.new(2011, 1, 1)
      )
      document.save!(validate: false)
      document
    end
    let(:ppi_document) do
      document = Document.new(
        published: true,
        local_administration_unit: lau,
        ppi_public_until: Time.new(2025, 1, 1)
      )
      document.save!(validate: false)
      document
    end

    describe Document do
      it 'can :read published document' do
        published_document
        expect(subject.can? :read, Document).to be true
        expect(subject.can? :read, published_document).to be true
        expect(Document.all.accessible_by(subject)).to eq [published_document]
      end
      it 'cannot :read unpublished document' do
        unpublished_document
        expect(subject.cannot? :read, unpublished_document).to be true
        expect(Document.all.accessible_by(subject)).to eq []
      end
      it 'can :read document with Personally identifiable information in time' do
        ppi_document
        expect(subject.can? :read, ppi_document).to be true
        expect(Document.all.accessible_by(subject)).to eq [ppi_document]
      end
      it 'cannot :read document with expired Personally identifiable information' do
        expired_ppi_document
        expect(subject.cannot? :read, expired_ppi_document).to be true
        expect(Document.all.accessible_by(subject)).to eq []
      end
      it 'cannot :create, :update, :destroy' do
        expect(subject.cannot? :create, Document).to be true
        expect(subject.cannot? :update, Document).to be true
        expect(subject.cannot? :destroy, Document).to be true
      end
    end

    describe Event do

      # due to inverse_of doesn't work with polymorfic,
      # document has to be persisted in following tests

      context 'when Document is published and event is not removed' do
        it 'can :read' do
          event = published_document.events.build
          event.save!(validate: false)
          expect(subject.can?(:read, event)).to be true
          expect(Event.all.accessible_by(subject)).to eq [event]
        end
        it 'cannot :read, :create, :update, :destroy' do
          event = unpublished_document.events.build
          expect(subject.cannot?(:read, event)).to be true
          expect(subject.cannot?(:create, event)).to be true
          expect(subject.cannot?(:update, event)).to be true
          expect(subject.cannot?(:destroy, event)).to be true
        end
      end

      context 'when Document is not published' do
        it 'cannot read' do
          event = unpublished_document.events.build
          event.save!(validate: false)
          expect(subject.cannot?(:read, event)).to be true
          expect(Event.all.accessible_by(subject)).to eq []
        end
      end

      context 'when event is removed' do
        it 'cannot :read' do
          event = published_document.events.build(removed_by: user)
          event.save!(validate: false)
          expect(subject.cannot?(:read, event)).to be true
          expect(Event.all.accessible_by(subject)).to eq []
        end
      end
      context 'when Document has exipred ppi_public_until' do
        it 'cannot :read' do
          event = expired_ppi_document.events.build
          event.save!(validate: false)
          expect(subject.cannot?(:read, event)).to be true
          expect(Event.all.accessible_by(subject)).to eq []
        end
      end
    end

    describe LocalAdministrationUnit do
      let(:lau) { FactoryGirl.create(:local_administration_unit) }
      it 'can :read' do
        expect(subject.can? :read, LocalAdministrationUnit).to be true
        expect(subject.can? :read, lau).to be true
      end

      it 'cannot :create, :update, destroy' do
        expect(subject.cannot? :create, lau).to be true
        expect(subject.cannot? :update, lau).to be true
        expect(subject.cannot? :destroy, lau).to be true
      end
    end

    describe LocalAdministrationUnitAdmin do
      let(:lau_admin)  { FactoryGirl.create(:local_administration_unit_admin) }
      it 'cannot :read, :create, :update, :destroy' do
        expect(subject.cannot? :create, lau_admin).to be true
        expect(subject.cannot? :read, lau_admin).to be true
        expect(subject.cannot? :update, lau_admin).to be true
        expect(subject.cannot? :destroy, lau_admin).to be true
      end
    end

    describe IncomeEmailAddress do
      let(:income_email)  { FactoryGirl.create(:income_email_address) }
      it 'cannot :read, :create, :update, :destroy' do
        expect(subject.cannot? :create, income_email).to be true
        expect(subject.cannot? :read, income_email).to be true
        expect(subject.cannot? :update, income_email).to be true
        expect(subject.cannot? :destroy, income_email).to be true
      end
    end

    describe User do
      it 'cannot :read, :update, :destroy other users' do
        another_user = FactoryGirl.create(:user)
        expect(subject.cannot? :read, User).to be true
        expect(subject.cannot? :read, another_user).to be true
        expect(subject.cannot? :update, another_user).to be true
        expect(subject.cannot? :destroy, another_user).to be true
      end

      it 'can :update myself' do
        user.save!
        expect(subject.can? :update, user).to be true
      end
    end
  end

  context 'Local Administration Unit Admin' do
    let(:lau_admin) do
      FactoryGirl.create(
        :local_administration_unit_admin,
        user: user,
        role: 'admin')
    end
    let(:other_lau_admin) do
      FactoryGirl.create(
        :local_administration_unit_admin,
        role: 'admin')
    end
    let(:lau) { lau_admin.local_administration_unit }

    describe LocalAdministrationUnitAdmin do
      it 'can :read, :update, :destroy my LAU' do
        expect(subject.can? :create, lau_admin).to be true
        expect(subject.can? :read, lau_admin).to be true
        expect(subject.can? :update, lau_admin).to be true
        expect(subject.can? :destroy, lau_admin).to be true
      end

      it 'cannot :read, :update, :destory other LAU' do
        expect(subject.cannot? :create, other_lau_admin).to be true
        expect(subject.cannot? :read, other_lau_admin).to be true
        expect(subject.cannot? :update, other_lau_admin).to be true
        expect(subject.cannot? :destroy, other_lau_admin).to be true
      end
    end

    describe IncomeEmailAddress do
      let(:income_email) do
        FactoryGirl.create(
          :income_email_address,
          local_administration_unit: lau
        )
      end
      let(:other_income_email) do
        FactoryGirl.create(
          :income_email_address,
          local_administration_unit: lau
        )
      end
      it 'can :read, :create, :update, :destroy my LAU' do
        expect(subject.can? :create, income_email).to be true
        expect(subject.can? :read, income_email).to be true
        expect(subject.can? :update, income_email).to be true
        expect(subject.can? :destroy, income_email).to be true
      end

      it 'cannot :read, :create, :update, :destroy other LAU' do
        expect(subject.can? :create, other_income_email).to be true
        expect(subject.can? :read, other_income_email).to be true
        expect(subject.can? :update, other_income_email).to be true
        expect(subject.can? :destroy, other_income_email).to be true
      end
    end
  end

  context 'Local Administration Unit Operator' do
    let(:lau_admin) do
      FactoryGirl.create(
        :local_administration_unit_admin,
        user: user,
        role: 'operator')
    end
    let(:lau) { lau_admin.local_administration_unit }
    let(:unpublished_document) do
      document = Document.new(published: false, local_administration_unit: lau)
      document.save!(validate: false)
      document
    end
    let(:published_document) do
      document = Document.new(published: true, local_administration_unit: lau)
      document.save!(validate: false)
      document
    end
    let(:expired_ppi_document) do
      document = Document.new(
        published: true,
        local_administration_unit: lau,
        ppi_public_until: Time.new(2011, 1, 1)
      )
      document.save!(validate: false)
      document
    end
    let(:ppi_document) do
      document = Document.new(
        published: true,
        local_administration_unit: lau,
        ppi_public_until: Time.new(2025, 1, 1)
      )
      document.save!(validate: false)
      document
    end

    describe Document do
      it 'can :read published document' do
        published_document
        expect(subject.can?(:read, published_document)).to be true
        expect(Document.all.accessible_by(subject)).to eq [published_document]
      end
      it 'can :read expred ppi_public_until document' do
        expired_ppi_document
        expect(subject.can?(:read, expired_ppi_document)).to be true
        expect(Document.all.accessible_by(subject)).to eq [expired_ppi_document]
      end
      it 'can :read unpublished doucment' do
        unpublished_document
        expect(subject.can?(:read, unpublished_document)).to be true
        expect(Document.all.accessible_by(subject)).to eq [unpublished_document]
      end
      it 'cannot :create, :update, :destory document' do
        unpublished_document
        expect(subject.cannot?(:create, Document)).to be true
        expect(subject.cannot?(:update, unpublished_document)).to be true
        expect(subject.cannot?(:destroy, unpublished_document)).to be true
      end
    end

    describe Event do
      it 'can read event when document is unpublished' do
        event = unpublished_document.events.build
        event.save!(validate: false)
        expect(subject.can?(:read, event)).to be true
        expect(Event.all.accessible_by(subject)).to eq [event]
      end

      it 'can :read event when document has expired ppi_public_until' do
        event = expired_ppi_document.events.build
        event.save!(validate: false)
        expect(subject.can?(:read, event)).to be true
        expect(Event.all.accessible_by(subject)).to eq [event]
      end

      it 'can read removed event when document is unpublished' do
        event = unpublished_document.events.build(removed_by: user)
        event.save!(validate: false)
        expect(subject.can?(:read, event)).to be true
        expect(Event.all.accessible_by(subject)).to eq [event]
      end
      it 'can read removed event when document is published' do
        event = published_document.events.build(removed_by: user)
        event.save!(validate: false)
        expect(subject.can?(:read, event)).to be true
        expect(Event.all.accessible_by(subject)).to eq [event]
      end

      it 'cannot :create, :update, :destory event' do
        event = unpublished_document.events.build
        expect(subject.cannot?(:create, event)).to be true
        expect(subject.cannot?(:update, event)).to be true
        expect(subject.cannot?(:destory, event)).to be true
      end
    end

    describe LocalAdministrationUnitAdmin do
      it 'can :read my LAU' do
        expect(subject.can? :read, lau_admin).to be true
      end

      it 'cannot :create, :update, :destroy my LAU' do
        expect(subject.cannot? :create, lau_admin).to be true
        expect(subject.cannot? :update, lau_admin).to be true
        expect(subject.cannot? :destroy, lau_admin).to be true
      end
    end

    describe IncomeEmailAddress do
      let(:income_email)  { FactoryGirl.create(:income_email_address) }
      it 'can :read, :create, :update, :destroy my LAU' do
        expect(subject.can? :create, income_email)
        expect(subject.can? :read, income_email)
        expect(subject.can? :update, income_email)
        expect(subject.can? :destroy, income_email)
      end
    end
  end
end
