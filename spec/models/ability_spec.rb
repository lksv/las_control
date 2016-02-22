require 'rails_helper'

RSpec.describe Ability, type: :model do
  let(:user) { FactoryGirl.build(:user) }
  let(:subject) { Ability.new(user) }
  context 'public access' do
    describe Document do
      it 'can :read' do
        expect(subject.can? :read, Document).to be true
        expect(subject.can? :read, Document.new).to be true
      end
      it 'cannot :create, :update, :destroy' do
        expect(subject.cannot? :create, Document).to be true
        expect(subject.cannot? :update, Document).to be true
        expect(subject.cannot? :destroy, Document).to be true
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
