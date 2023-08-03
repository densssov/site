require 'rails_helper'
require 'cgi'

RSpec.describe PagesController, type: :controller do
  context 'Проверка добавления страницы/подстраницы' do
    it "С заданными параметрами добавит страницу" do
      params = { parent_id: nil, name: "test_name", header: "test_header", description: "test_description" } 
      post :create, { page: params }
      expect(Page.count).to eq(1)
    end

    it "С заданными параметрами добавит подстраницу" do
      page = Page.new({ parent_id: nil, name: "test_name", header: "test_header", description: "test_description" } )
      page.save
      params = { parent_id: page.id, name: "subtest_name", header: "subtest_header", description: "subtest_description" }
      post :create, { page: params }
      expect(Page.count).to eq(2)
    end
  end

  context 'Проверка перенаправления на страницы/подстраницы' do
    it 'После создания главной страницы перенаправит на ее адрес' do
      params = { parent_id: nil, name: "test_name", header: "test_header", description: "test_description" } 
      post :create, { page: params }

      expect(response).to redirect_to("/test_name")
    end

    it 'После создания подстраницы перенаправит на ее адрес' do
      page = Page.new({ parent_id: nil, name: "главная_страница", header: "test_header", description: "test_description" } )
      page.save
      params = { parent_id: page.id, name: "subtest_name", header: "subtest_header", description: "subtest_description" }
      post :create, { names: 'glavnaya_stranitsa', page: params }

      expect(response).to redirect_to("/glavnaya_stranitsa/subtest_name")
    end

    it "После обновления отправит на главную страницу" do
      page = Page.new({ parent_id: nil, name: "glavnaya_stranitsa", header: "test_header", description: "test_description" } )
      page.save

      params = { parent_id: nil, name: "subtest_name", header: "subtest_header", description: "subtest_description" }
      patch :update, { names: 'glavnaya_stranitsa', page: params }

      expect(response).to redirect_to("/subtest_name")
    end

    it "После обновления отправит на нужную страницу" do
      page = Page.create({ parent_id: nil, name: "главная_страница", header: "test_header", description: "test_description" } )
      page = Page.create({ parent_id: page.id, name: "subtest_name", header: "subtest_header", description: "subtest_description" } )
      params = { parent_id: page.id, name: "subtest_name21", header: "subtest_header", description: "subtest_description" }
      patch :update, { names: "glavnaya_stranitsa/subtest_name", page: params }

      expect(response).to redirect_to("/glavnaya_stranitsa/subtest_name21")
    end

    it "Отправит 404 так как страницы нет" do 
      expect{ get :show, {names: "main"} }.to raise_error(ActionController::RoutingError)
    end

    it "Отправит 404 так как неверное имя страницы нет" do 
      Page.create({ parent_id: nil, name: "главная_страница", header: "test_header", description: "test_description" } )
      expect{ get :show, {names: "main"} }.to raise_error(ActionController::RoutingError)
    end

    it "Отправит 404 так как неверный путь страницы в конце" do 
      page = Page.create({ parent_id: nil, name: "главная_страница", header: "test_header", description: "test_description" } )
      page = Page.create({ parent_id: page.id, name: "subtest_name", header: "subtest_header", description: "subtest_description" } )
      expect{ get :show, {names: "glavnaya_stranitsa/main"} }.to raise_error(ActionController::RoutingError)
    end

    it "Отправит 404 так как неверный путь страницы в начале" do 
      page = Page.create({ parent_id: nil, name: "главная_страница", header: "test_header", description: "test_description" } )
      page = Page.create({ parent_id: page.id, name: "subtest_name", header: "subtest_header", description: "subtest_description" } )
      expect{ get :show, {names: "main/subtest_name"} }.to raise_error(ActionController::RoutingError)
    end
  end

  context 'Проверка преобразования описания добавленного текста' do
    it 'Преобразует строку ** в ширный' do
      params = { parent_id: nil, name: "test_name", header: "test_header", description: "*test_description*" }
      post :create, { page: params }

      expect(Page.last.description).to eq("<b>test_description</b>")
    end

    it "Преобразует строку \\\\ в курсив" do
      params = { parent_id: nil, name: "test_name", header: "test_header", description: "\\test_description\\" }
      post :create, { page: params }

      expect(Page.last.description).to eq("<i>test_description</i>")
    end

    it "Преобразует строку (()) в ссылку" do
      params = { parent_id: nil, name: "test_name", header: "test_header", description: "((test/test2 test_description))" }
      post :create, { page: params }

      expect(Page.last.description).to eq("<a href='http://0.0.0.0:3000/test/test2'>test_description</a>")
    end
  end
end
