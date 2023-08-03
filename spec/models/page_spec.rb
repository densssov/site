require 'rails_helper'

RSpec.describe Page, type: :model do
  context 'Проверка добавления страницы/подстраницы' do
    let(:params) { { parent_id: nil, name: "test_name", header: "test_header", description: "test_description" } }

    it "Добавит главную страницу без ошибок" do
      page = Page.new(params)
      page.save
      expect(Page.count).to eq(1)
    end

    it "Добавит главную страницу и ее подстраницу" do 
      main_page = Page.new(params)
      main_page.save

      sub_page = Page.new({ parent_id: nil, name: "subtest_name", header: "subtest_header", description: "subtest_description" })
      sub_page.save

      expect(Page.count).to eq(2)
    end

    it "Не будет добавлять страницу" do 
      page = Page.new({ parent_id: nil, name: "test)*&%$#_name", header: "test_header", description: "test_description" })
      expect(page.valid?).to eq(false)
    end
  end

  context 'Проверка преобразования описания страницы' do
    it "Преобразует строку ** в ширный" do
      params = { parent_id: nil, name: "test_name", header: "test_header", description: "*test_description*" }
      page = Page.new(params)
      page.save
      expect(Page.last.description).to eq("<b>test_description</b>")
    end

    it "Преобразует строку \\\\ в курсив" do
      params = { parent_id: nil, name: "test_name", header: "test_header", description: "\\test_description\\" }
      page = Page.new(params)
      page.save
      expect(Page.last.description).to eq("<i>test_description</i>")
    end

    it "Преобразует строку (()) в ссылку" do
      params = { parent_id: nil, name: "test_name", header: "test_header", description: "((test/test2 test_description))" }
      page = Page.new(params)
      page.save
      expect(Page.last.description).to eq("<a href='http://0.0.0.0:3000/test/test2'>test_description</a>")
    end
  end

  context 'Проверка обратного преобразования описания страницы' do
    it "Преобразует строку ** в ширный" do
      params = { parent_id: nil, name: "test_name", header: "test_header", description: "*test_description*" }
      page = Page.new(params)
      page.save
      expect(Page.last.unreplace_description).to eq("*test_description*")
    end

    it "Преобразует строку \\\\ в курсив" do
      params = { parent_id: nil, name: "test_name", header: "test_header", description: "\\test_description\\" }
      page = Page.new(params)
      page.save
      expect(Page.last.unreplace_description).to eq("\\test_description\\")
    end

    it "Преобразует строку (()) в ссылку" do
      params = { parent_id: nil, name: "test_name", header: "test_header", description: "((test/test2 test_description))" }
      page = Page.new(params)
      page.save
      expect(Page.last.unreplace_description).to eq("((test/test2 test_description))")
    end
  end

end
