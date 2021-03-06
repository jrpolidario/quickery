require 'rails_helper'

RSpec.describe Employee, type: :model do
  describe 'after create' do
    let!(:country_1) { create(:country, name: 'United States of Earth') }
    let!(:country_2) { create(:country, name: 'Valhalla') }
    let!(:company_1) { create(:company, country: country_1) }
    let!(:company_2) { create(:company, country: country_2) }
    let!(:branch_1) { create(:branch, company: company_1) }
    let!(:branch_2) { create(:branch, company: company_2) }

    context 'when quickery-defined foreign_key attribute is not set' do
      let(:employee_4) { build(:employee, branch: nil) }

      it 'has quickery-defined attributes equal to nil' do
        employee_4.tap do |employee|
          expect(employee.branch_company_country_name).to be nil
          expect(employee.branch_company_country_id).to be nil
          expect(employee.branch_company_name).to be nil

          employee.save!
          employee.reload

          expect(employee).to be_persisted

          expect(employee.branch_company_country_name).to be nil
          expect(employee.branch_company_country_id).to be nil
          expect(employee.branch_company_name).to be nil
        end
      end

      context 'when exists a corresponding *_is_synced attribute and it has not yet been set (still false)' do
        before do
          expect(employee_4).to_not have_attribute :branch_company_country_id_is_synced
          expect(employee_4).to have_attribute :branch_company_country_name_is_synced
          expect(employee_4).to have_attribute :branch_company_name_is_synced
          employee_4.assign_attributes(branch_company_country_name_is_synced: false, branch_company_name_is_synced: false)
        end

        it 'marks "set" the quickery-attributes via the corresponding *is_synced attributes' do
          employee_4.tap do |employee|
            employee.save!
            employee.reload
            expect(employee.branch_company_country_name_is_synced).to eq true
            expect(employee.branch_company_name_is_synced).to eq true
          end
        end
      end
    end

    context 'when quickery-defined foreign_key attribute is set' do
      let(:employee_1) { build(:employee, branch: branch_1) }
      let(:employee_2) { build(:employee, branch: branch_2) }
      let(:employee_3) { build(:employee, branch: branch_2) }

      it 'has quickery-defined attributes the same values as their mapped associated attributes' do
        employee_1.tap do |employee|
          expect(employee.branch_company_country_name).to be nil
          expect(employee.branch_company_country_id).to be nil
          expect(employee.branch_company_name).to be nil

          employee.save!
          employee.reload

          expect(employee).to be_persisted

          expect(employee.branch_company_country_name).to eq 'United States of Earth'
          expect(employee.branch_company_country_id).to eq country_1.id
          expect(employee.branch_company_name).to eq company_1.name
        end

        employee_2.tap do |employee|
          expect(employee.branch_company_country_name).to be nil
          expect(employee.branch_company_country_id).to be nil
          expect(employee.branch_company_name).to be nil

          employee.save!
          employee.reload

          expect(employee).to be_persisted

          expect(employee.branch_company_country_name).to eq 'Valhalla'
          expect(employee.branch_company_country_id).to eq country_2.id
          expect(employee.branch_company_name).to eq company_2.name
        end

        employee_3.tap do |employee|
          expect(employee.branch_company_country_name).to be nil
          expect(employee.branch_company_country_id).to be nil
          expect(employee.branch_company_name).to be nil

          employee.save!
          employee.reload

          expect(employee).to be_persisted

          expect(employee.branch_company_country_name).to eq 'Valhalla'
          expect(employee.branch_company_country_id).to eq country_2.id
          expect(employee.branch_company_name).to eq company_2.name
        end
      end

      context 'when exists a corresponding *_is_synced attribute and it has not yet been set (still false)' do
        before do
          expect(employee_1).to_not have_attribute :branch_company_country_id_is_synced
          expect(employee_1).to have_attribute :branch_company_country_name_is_synced
          expect(employee_1).to have_attribute :branch_company_name_is_synced
          employee_1.assign_attributes(branch_company_country_name_is_synced: false, branch_company_name_is_synced: false)
        end

        it 'marks "set" the quickery-attributes via the corresponding *is_synced attributes' do
          employee_1.tap do |employee|
            employee.save!
            employee.reload
            expect(employee.branch_company_country_name_is_synced).to eq true
            expect(employee.branch_company_name_is_synced).to eq true
          end
        end
      end
    end
  end

  describe 'after update' do
    let!(:country_1) { create(:country, name: 'United States of Earth') }
    let!(:country_2) { create(:country, name: 'Valhalla') }
    let!(:company_1) { create(:company, country: country_1) }
    let!(:company_2) { create(:company, country: country_2) }
    let!(:branch_1) { create(:branch, company: company_1) }
    let!(:branch_2) { create(:branch, company: company_2) }
    let!(:employee_1) { create(:employee) }
    let!(:employee_2) { create(:employee) }
    let!(:employee_3) { create(:employee) }
    let!(:employee_4) { create(:employee) }

    context 'when non-quickery-defined foreign_key attribute is changed' do
      before(:each) do
        employee_1.name = 'emp1'
        employee_2.name = 'emp2'
        employee_3.name = 'emp3'
        employee_4.name = 'emp4'
      end

      it 'does not change quickery-defined attributes' do
        employee_1.tap do |employee|
          expect{
            employee.save!
            employee.reload
          }.to not_change(employee, :branch_company_country_name)
            .and not_change(employee, :branch_company_country_id)
        end

        employee_2.tap do |employee|
          expect{
            employee.save!
            employee.reload
          }.to not_change(employee, :branch_company_country_name)
            .and not_change(employee, :branch_company_country_id)
        end

        employee_3.tap do |employee|
          expect{
            employee.save!
            employee.reload
          }.to not_change(employee, :branch_company_country_name)
            .and not_change(employee, :branch_company_country_id)
        end

        employee_4.tap do |employee|
          expect{
            employee.save!
            employee.reload
          }.to not_change(employee, :branch_company_country_name)
            .and not_change(employee, :branch_company_country_id)
        end
      end

      context 'when exists a corresponding *_is_synced attribute and it has not yet been set (still false)' do
        before do
          expect(employee_1).to_not have_attribute :branch_company_country_id_is_synced
          expect(employee_1).to have_attribute :branch_company_country_name_is_synced
          expect(employee_1).to have_attribute :branch_company_name_is_synced
          employee_1.update_columns(branch_company_country_name_is_synced: false, branch_company_name_is_synced: false)
        end

        it 'does not mark "set" the quickery-attributes' do
          employee_1.tap do |employee|
            employee.save!
            employee.reload
            expect(employee.branch_company_country_name_is_synced).to eq false
            expect(employee.branch_company_name_is_synced).to eq false
          end
        end
      end
    end

    context 'when quickery-defined foreign_key attributes changed' do

      before(:each) do
        employee_1.branch = branch_1
        employee_2.branch = branch_2
        employee_3.branch = branch_2
        employee_4.branch = nil
      end

      it 'has quickery-defined attributes the same values as their mapped associated attributes' do
        employee_1.tap do |employee|
          branch_was = Branch.find(employee.branch_id_was)
          expect(employee.branch_company_country_name).to eq branch_was.company.country.name
          expect(employee.branch_company_country_id).to eq branch_was.company.country.id
          expect(employee.branch_company_name).to eq branch_was.company.name

          employee.save!
          employee.reload

          expect(employee).to be_persisted

          expect(employee.branch_company_country_name).to eq 'United States of Earth'
          expect(employee.branch_company_country_id).to eq country_1.id
          expect(employee.branch_company_name).to eq company_1.name
        end

        employee_2.tap do |employee|
          branch_was = Branch.find(employee.branch_id_was)
          expect(employee.branch_company_country_name).to eq branch_was.company.country.name
          expect(employee.branch_company_country_id).to eq branch_was.company.country.id
          expect(employee.branch_company_name).to eq branch_was.company.name

          employee.save!
          employee.reload

          expect(employee).to be_persisted

          expect(employee.branch_company_country_name).to eq 'Valhalla'
          expect(employee.branch_company_country_id).to eq country_2.id
          expect(employee.branch_company_name).to eq company_2.name
        end

        employee_3.tap do |employee|
          branch_was = Branch.find(employee.branch_id_was)
          expect(employee.branch_company_country_name).to eq branch_was.company.country.name
          expect(employee.branch_company_country_id).to eq branch_was.company.country.id
          expect(employee.branch_company_name).to eq branch_was.company.name

          employee.save!
          employee.reload

          expect(employee).to be_persisted

          expect(employee.branch_company_country_name).to eq 'Valhalla'
          expect(employee.branch_company_country_id).to eq country_2.id
          expect(employee.branch_company_name).to eq company_2.name
        end

        employee_4.tap do |employee|
          branch_was = Branch.find(employee.branch_id_was)
          expect(employee.branch_company_country_name).to eq branch_was.company.country.name
          expect(employee.branch_company_country_id).to eq branch_was.company.country.id
          expect(employee.branch_company_name).to eq branch_was.company.name

          employee.save!
          employee.reload

          expect(employee).to be_persisted

          expect(employee.branch_company_country_name).to eq nil
          expect(employee.branch_company_country_id).to eq nil
          expect(employee.branch_company_name).to eq nil
        end
      end

      context 'when exists a corresponding *_is_synced attribute and it has not yet been set (still false)' do
        before do
          expect(employee_1).to_not have_attribute :branch_company_country_id_is_synced
          expect(employee_1).to have_attribute :branch_company_country_name_is_synced
          expect(employee_1).to have_attribute :branch_company_name_is_synced
          employee_1.update_columns(branch_company_country_name_is_synced: false, branch_company_name_is_synced: false)
        end

        it 'marks "set" the quickery-attributes via the corresponding *is_synced attributes' do
          employee_1.tap do |employee|
            employee.save!
            employee.reload
            expect(employee.branch_company_country_name_is_synced).to eq true
            expect(employee.branch_company_name_is_synced).to eq true
          end
        end
      end
    end
  end

  context 'class methods' do
    describe 'quickery_builders' do
      it 'returns a Hash of "quickery attribute" => Quickery::QuickeryBuilder objects' do
        expect(Employee.quickery_builders.keys).to eq [:branch_company_country_name, :branch_company_country_id, :branch_company_name]
        expect(Employee.quickery_builders.values).to all be_a(Quickery::QuickeryBuilder)
      end
    end
  end

  context 'instance methods' do
    let(:employee) { create(:employee, branch_id: nil) }

    describe 'recreate_quickery_cache!' do
      let!(:country) { create(:country, name: 'United States of Earth') }
      let!(:company) { create(:company, country: country) }
      let!(:branch) { create(:branch, company: company) }

      it 'updates all quickery-attributes to current correct mapped values' do
        employee.update_columns(branch_id: branch.id)
        employee.reload

        expect(employee.branch_company_country_id).to be nil
        expect(employee.branch_company_country_name).to be nil
        expect(employee.branch_company_name).to be nil


        employee.recreate_quickery_cache!
        employee.reload

        expect(employee.branch_company_country_id).to eq country.id
        expect(employee.branch_company_country_name).to eq country.name
        expect(employee.branch_company_name).to eq company.name
      end
    end

    describe 'determine_quickery_value' do
      let!(:country) { create(:country, name: 'United States of Earth') }
      let!(:company) { create(:company, country: country) }
      let!(:branch) { create(:branch, company: company) }

      it 'returns current correct mapped value' do
        employee.branch = branch
        expect(employee.determine_quickery_value(:branch_company_country_id)).to eq country.id
        expect(employee.determine_quickery_value(:branch_company_country_name)).to eq country.name
        expect(employee.determine_quickery_value(:branch_company_name)).to eq company.name
        expect(employee.branch_company_country_id).to eq nil
        expect(employee.branch_company_country_name).to eq nil
        expect(employee.branch_company_name).to eq nil
      end
    end

    describe 'determine_quickery_values' do
      let!(:country) { create(:country, name: 'United States of Earth') }
      let!(:company) { create(:company, country: country) }
      let!(:branch) { create(:branch, company: company) }

      it 'returns current correct mapped value' do
        employee.branch = branch
        quickery_values = employee.determine_quickery_values
        expect(quickery_values[:branch_company_country_id]).to eq country.id
        expect(quickery_values[:branch_company_country_name]).to eq country.name
        expect(quickery_values[:branch_company_name]).to eq company.name
        expect(employee.branch_company_country_id).to eq nil
        expect(employee.branch_company_country_name).to eq nil
        expect(employee.branch_company_name).to eq nil
      end
    end

    describe 'autoload_quickery_attributes!' do
      let!(:country) { create(:country, name: 'United States of Earth') }
      let!(:company) { create(:company, country: country) }
      let!(:branch) { create(:branch, company: company) }

      it 'updates all remaining "un-synced" quickery-attributes (that have corresponding *_is_synced attribute) to current correct mapped values' do
        expect(employee).to_not have_attribute :branch_company_country_id_is_synced
        expect(employee).to have_attribute :branch_company_country_name_is_synced
        expect(employee).to have_attribute :branch_company_name_is_synced

        employee.update_columns(branch_id: branch.id, branch_company_country_name_is_synced: true, branch_company_name_is_synced: false)
        employee.reload

        expect(employee.branch_company_country_id).to be nil
        expect(employee.branch_company_country_name).to be nil
        expect(employee.branch_company_name).to be nil

        employee.autoload_unsynced_quickery_attributes!
        employee.reload

        expect(employee.branch_company_country_id).to be nil
        expect(employee.branch_company_country_name).to eq nil
        expect(employee.branch_company_name).to eq company.name
      end
    end
  end
end
