require 'rails_helper'

RSpec.describe Country, type: :model do
  describe 'after update' do
    let!(:country_1) { create(:country, name: 'United States of Earth') }
    let!(:country_2) { create(:country, name: 'Valhalla') }
    let!(:company_1) { create(:company, country: country_1, name: 'Company1') }
    let!(:company_2) { create(:company, country: country_2, name: 'Company2') }
    let!(:branch_1) { create(:branch, company: company_1) }
    let!(:branch_2) { create(:branch, company: company_2) }
    let!(:employee_1) { create(:employee, branch: branch_1) }
    let!(:employee_2) { create(:employee, branch: branch_2) }
    let!(:employee_3) { create(:employee, branch: branch_2) }
    let!(:employee_4) { create(:employee, branch: nil) }
    let!(:employee_5) { create(:employee, branch: create(:branch)) }

    context 'when quickery-defined dependee attribute is changed' do
      before(:each) do
        country_1.name = 'newcountry1'
        country_2.name = 'newcountry2'
      end

      it 'updates nested children records that have quickery-defined attributes' do
        expect(employee_4.branch_company_country_name).to eq nil
        expect(employee_4.branch_company_country_id).to eq nil
        expect(employee_4.branch_company_name).to eq nil
        expect(employee_5.branch_company_country_name).to_not eq nil
        expect(employee_5.branch_company_country_id).to_not eq nil
        expect(employee_5.branch_company_name).to_not eq nil

        country_1.tap do |country|
          expect(employee_1.branch_company_country_name).to eq 'United States of Earth'
          expect(employee_1.branch_company_country_id).to eq country_1.id
          expect(employee_1.branch_company_name).to eq 'Company1'

          country.save!

          employee_1.reload
          expect(employee_1.branch_company_country_name).to eq 'newcountry1'
          expect(employee_1.branch_company_country_id).to eq country_1.id
          expect(employee_1.branch_company_name).to eq 'Company1'
        end

        country_2.tap do |country|
          expect(employee_2.branch_company_country_name).to eq 'Valhalla'
          expect(employee_2.branch_company_country_id).to eq country_2.id
          expect(employee_2.branch_company_name).to eq 'Company2'
          expect(employee_3.branch_company_country_name).to eq 'Valhalla'
          expect(employee_3.branch_company_country_id).to eq country_2.id
          expect(employee_3.branch_company_name).to eq 'Company2'

          country.save!

          employee_2.reload
          expect(employee_2.branch_company_country_name).to eq 'newcountry2'
          expect(employee_2.branch_company_country_id).to eq country_2.id
          expect(employee_2.branch_company_name).to eq 'Company2'
          employee_3.reload
          expect(employee_3.branch_company_country_name).to eq 'newcountry2'
          expect(employee_3.branch_company_country_id).to eq country_2.id
          expect(employee_3.branch_company_name).to eq 'Company2'
        end

        employee_4.reload
        expect(employee_4.branch_company_country_name).to eq nil
        expect(employee_4.branch_company_country_id).to eq nil
        expect(employee_4.branch_company_name).to eq nil

        current_employee_5_attributes = employee_5.attributes
        employee_5.reload
        expect(employee_5.branch_company_country_name).to eq current_employee_5_attributes['branch_company_country_name']
        expect(employee_5.branch_company_country_id).to eq current_employee_5_attributes['branch_company_country_id']
        expect(employee_5.branch_company_name).to eq current_employee_5_attributes['branch_company_name']
      end
    end

    context 'when non-quickery-defined foreign_key attribute is changed' do
      before(:each) do
        country_1.category = create(:category)
        country_2.category = create(:category)
      end

      it 'does not update nested children records that have quickery-defined attributes' do
        expect(employee_4.branch_company_country_name).to eq nil
        expect(employee_4.branch_company_country_id).to eq nil
        expect(employee_4.branch_company_name).to eq nil

        country_1.tap do |country|
          expect(employee_1.branch_company_country_name).to eq 'United States of Earth'
          expect(employee_1.branch_company_country_id).to eq company_1.id

          country.save!

          employee_1.reload
          expect(employee_1.branch_company_country_name).to eq 'United States of Earth'
          expect(employee_1.branch_company_country_id).to eq company_1.id
        end

        country_2.tap do |country|
          expect(employee_2.branch_company_country_name).to eq 'Valhalla'
          expect(employee_2.branch_company_country_id).to eq country_2.id
          expect(employee_2.branch_company_name).to eq 'Company2'
          expect(employee_3.branch_company_country_name).to eq 'Valhalla'
          expect(employee_3.branch_company_country_id).to eq country_2.id
          expect(employee_3.branch_company_name).to eq 'Company2'

          country.save!

          employee_2.reload
          expect(employee_2.branch_company_country_name).to eq 'Valhalla'
          expect(employee_2.branch_company_country_id).to eq country_2.id
          expect(employee_2.branch_company_name).to eq 'Company2'
          employee_3.reload
          expect(employee_3.branch_company_country_name).to eq 'Valhalla'
          expect(employee_3.branch_company_country_id).to eq country_2.id
          expect(employee_3.branch_company_name).to eq 'Company2'
        end

        employee_4.reload
        expect(employee_4.branch_company_country_name).to eq nil
        expect(employee_4.branch_company_country_id).to eq nil
        expect(employee_4.branch_company_name).to eq nil
      end
    end
  end

  describe 'after destroy' do
    let!(:country_1) { create(:country, name: 'United States of Earth') }
    let!(:country_2) { create(:country, name: 'Valhalla') }
    let!(:company_1) { create(:company, country: country_1, name: 'Company1') }
    let!(:company_2) { create(:company, country: country_2, name: 'Company2') }
    let!(:branch_1) { create(:branch, company: company_1) }
    let!(:branch_2) { create(:branch, company: company_2) }
    let!(:employee_1) { create(:employee, branch: branch_1) }
    let!(:employee_2) { create(:employee, branch: branch_2) }
    let!(:employee_3) { create(:employee, branch: branch_2) }
    let!(:employee_4) { create(:employee, branch: nil) }
    let!(:employee_5) { create(:employee, branch: create(:branch)) }

    it 'updates nested children records that have quickery-defined attributes with nil' do
      expect(employee_4.branch_company_country_name).to eq nil
      expect(employee_4.branch_company_country_id).to eq nil
      expect(employee_4.branch_company_name).to eq nil
      expect(employee_5.branch_company_country_name).to_not eq nil
      expect(employee_5.branch_company_country_id).to_not eq nil
      expect(employee_5.branch_company_name).to_not eq nil

      country_1.tap do |country|
        expect(employee_1.branch_company_country_name).to eq 'United States of Earth'
        expect(employee_1.branch_company_country_id).to eq country_1.id
        expect(employee_1.branch_company_name).to eq 'Company1'

        country.destroy

        employee_1.reload
        expect(employee_1.branch_company_country_name).to eq nil
        expect(employee_1.branch_company_country_id).to eq nil
        expect(employee_1.branch_company_name).to eq 'Company1'
      end

      country_2.tap do |country|
        expect(employee_2.branch_company_country_name).to eq 'Valhalla'
        expect(employee_2.branch_company_country_id).to eq country_2.id
        expect(employee_2.branch_company_name).to eq 'Company2'
        expect(employee_3.branch_company_country_name).to eq 'Valhalla'
        expect(employee_3.branch_company_country_id).to eq country_2.id
        expect(employee_3.branch_company_name).to eq 'Company2'

        country.destroy

        employee_2.reload
        expect(employee_2.branch_company_country_name).to eq nil
        expect(employee_2.branch_company_country_id).to eq nil
        expect(employee_2.branch_company_name).to eq 'Company2'
        employee_3.reload
        expect(employee_3.branch_company_country_name).to eq nil
        expect(employee_3.branch_company_country_id).to eq nil
        expect(employee_3.branch_company_name).to eq 'Company2'
      end

      employee_4.reload
      expect(employee_4.branch_company_country_name).to eq nil
      expect(employee_4.branch_company_country_id).to eq nil
      expect(employee_4.branch_company_name).to eq nil

      employee_5.reload
      expect(employee_5.branch_company_country_name).to_not eq nil
      expect(employee_5.branch_company_country_id).to_not eq nil
      expect(employee_5.branch_company_name).to_not eq nil
    end
  end
end
