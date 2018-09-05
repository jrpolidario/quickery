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

          employee.save!
          employee.reload

          expect(employee).to be_persisted

          expect(employee.branch_company_country_name).to be nil
          expect(employee.branch_company_country_id).to be nil
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

          employee.save!
          employee.reload

          expect(employee).to be_persisted

          expect(employee.branch_company_country_name).to eq 'United States of Earth'
          expect(employee.branch_company_country_id).to eq country_1.id
        end

        employee_2.tap do |employee|
          expect(employee.branch_company_country_name).to be nil
          expect(employee.branch_company_country_id).to be nil

          employee.save!
          employee.reload

          expect(employee).to be_persisted

          expect(employee.branch_company_country_name).to eq 'Valhalla'
          expect(employee.branch_company_country_id).to eq country_2.id
        end

        employee_3.tap do |employee|
          expect(employee.branch_company_country_name).to be nil
          expect(employee.branch_company_country_id).to be nil

          employee.save!
          employee.reload

          expect(employee).to be_persisted

          expect(employee.branch_company_country_name).to eq 'Valhalla'
          expect(employee.branch_company_country_id).to eq country_2.id
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

    context 'when quickery-defined foreign_key attributes not changed' do
      before(:each) do
        employee_1.name = 'emp1'
        employee_2.name = 'emp2'
        employee_3.name = 'emp3'
        employee_4.name = 'emp4'
      end

      it 'does not changed quickery-defined attributes' do
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

          employee.save!
          employee.reload

          expect(employee).to be_persisted

          expect(employee.branch_company_country_name).to eq 'United States of Earth'
          expect(employee.branch_company_country_id).to eq country_1.id
        end

        employee_2.tap do |employee|
          branch_was = Branch.find(employee.branch_id_was)
          expect(employee.branch_company_country_name).to eq branch_was.company.country.name
          expect(employee.branch_company_country_id).to eq branch_was.company.country.id

          employee.save!
          employee.reload

          expect(employee).to be_persisted

          expect(employee.branch_company_country_name).to eq 'Valhalla'
          expect(employee.branch_company_country_id).to eq country_2.id
        end

        employee_3.tap do |employee|
          branch_was = Branch.find(employee.branch_id_was)
          expect(employee.branch_company_country_name).to eq branch_was.company.country.name
          expect(employee.branch_company_country_id).to eq branch_was.company.country.id

          employee.save!
          employee.reload

          expect(employee).to be_persisted

          expect(employee.branch_company_country_name).to eq 'Valhalla'
          expect(employee.branch_company_country_id).to eq country_2.id
        end

        employee_4.tap do |employee|
          branch_was = Branch.find(employee.branch_id_was)
          expect(employee.branch_company_country_name).to eq branch_was.company.country.name
          expect(employee.branch_company_country_id).to eq branch_was.company.country.id

          employee.save!
          employee.reload

          expect(employee).to be_persisted

          expect(employee.branch_company_country_name).to eq nil
          expect(employee.branch_company_country_id).to eq nil
        end
      end
    end
  end
end
