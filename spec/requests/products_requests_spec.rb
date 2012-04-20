require 'spec_helper'

describe "Products Requests" do
  context "when logged in as a basic user" do
    let!(:user) { Fabricate(:user, email: "foozberry@example.com", admin: true) }

    before(:each) do
      visit signin_path
      fill_in "Email",    with: user.email
      fill_in "Password", with: user.password
      click_button "Sign in"
    end

    context "#index" do
      let!(:category) { [Fabricate(:category, :id => 999)] }
      let!(:products) { [Fabricate(:product, :category_ids => 999), Fabricate(:product, :category_ids => 999)] }

      before(:each) do
        visit "/products/"
      end

      describe "pagination" do
        before(:all) { 30.times { FactoryGirl.create(:product) } }
        after(:all)  { Product.delete_all }

        it "should have a 'Next' button at the top of the screen" do
          page.should have_selector("a[rel$='next']")
        end

        it "should list each user" do
          Product.all[0..2].each do |product|
            page.should have_selector('td', text: product.title)
          end
        end
      end

      it "has category information for each product" do
        within("table#products") do
          products.each do |product|
            page.should have_selector("#product_#{product.id}_categories")
          end
        end
      end

      it "shows the corresponding categories for each product" do
        within("table#products") do
          products.each do |product|
            
            within("#product_#{product.id}_categories") do
              product.categories.each do |category|
                page.should have_content(category.name)
              end
            end
          end
        end
      end

      it "lists the products" do
        within("table#products") do
          products.each do |product|
            page.should have_selector("#product_#{product.id}")
          end
        end
      end

      it "links to the products" do
        within("table#products") do
          products.each do |product|
            page.should have_link(product.title, :href => product_path(product))
          end
        end
      end

      it "displays the product when clicking the link" do
        product = products.first
        within("#product_#{product.id}_add") do
          click_link(product.title)
        end
        current_path.should == product_path(product)
      end
    end

    context "show" do
      let!(:product) { Fabricate(:product) }

      before(:each) do
        visit product_path(product)
      end

      it "displays the title of the product" do
        # within("h1") do
          page.should have_content(product.title)
        # end
      end

      it "displays the description of the product" do
        page.should have_content(product.description)
      end

      it "displays the photo of the product" do
        page.should have_selector("img[src$='#{product.photo}']")
      end

      it "displays the price of the product" do
        page.should have_content(product.price)
      end

      it "displays the category of the product" do
        product.categories.each do |category|
          page.should have_content(category.name)
        end
      end

      it "has a link to all products page" do
        page.should have_selector("a[href$='#{products_path}']")
      end

      it "displays the add product page when clicking the link" do
        click_link("back to all products")
        current_path.should == products_path
      end
    end
  end

  context "when logged in as an admin user" do
    let!(:user) { Fabricate(:user, email: "foozberry2@example.com", admin: true) }

    before(:each) do
      visit signin_path
      fill_in "Email",    with: user.email
      fill_in "Password", with: user.password
      click_button "Sign in"
    end

    context "products" do
      let!(:category) { [Fabricate(:category, :id => 999)] }
      let!(:products) { [Fabricate(:product, :category_ids => 999), Fabricate(:product, :category_ids => 999)] }

      before(:each) do
        visit "/admin/products/"
      end

      it "has a link to the add product page" do
        page.should have_selector("a#add_product")
      end

      it "displays the add product page when clicking the link" do
        click_link("add_product")
        current_path.should == "/admin/products/new"
      end
    end

    context "edit" do
      let!(:product) { Fabricate(:product) }

      before(:each) do
        visit edit_admin_product_path(product)
      end

      it "displays a form" do
        page.should have_selector("form")
      end

      it "updates the title" do
        fill_in "Title", with: "Test Title"
        click_button "Update Product"
        page.should have_content("Test Title")
      end

      it "updates the description" do
        fill_in "Description", with: "New Description"
        click_button "Update Product"
        page.should have_content("New Description")
      end

      it "updates the price" do
        fill_in "Price", with: "4738"
        click_button "Update Product"
        page.should have_content("4738")
      end

      it "updates the photo" do
        pending "Check on selectors for images, etc"
        fill_in "Photo", with: "http://adigitalnative.com/photo.jpg"
        click_button "Update Product"
        page.should have_selector("img")
      end

      it "updates the categories" do
        pending "Need a way to test the selector"
      end

      it "updates the retired status" do
        pending "Need a way to test the checkbox"
      end

      context "the form" do

        it "asks for a title" do
          within("form") do
            page.should have_selector("label[for$='product_title']")
            page.should have_selector("input[id$='product_title']")
          end
        end

        it "knows the old title" do
          within("form") do
            page.should have_selector("input[id$='product_title'][value$='#{product.title}']")
          end
        end

        it "asks for a product description" do
          within("form") do
            page.should have_selector("label[for$='product_description']")
            page.should have_selector("textarea[id$='product_description']")
          end
        end

        it "knows the old description" do
          within("form") do
            page.should have_content(product.description)
          end
        end

        it "asks for a product price" do
          within("form") do
            page.should have_selector("label[for$='product_price']")
            page.should have_selector("input[id$='product_price']")
          end
        end

        it "knows the old product price" do
          within("form") do
            page.should have_selector("input[id$='product_price'][value$='#{product.price}']")
          end
        end

        it "asks for a product photo" do
          within("form") do
            page.should have_selector("label[for$='product_photo']")
            page.should have_selector("input[id$='product_photo']")
          end
        end

        it "knows the old photo" do
          within("form") do
            page.should have_selector("input[id$='product_photo'][value$='#{product.photo}']")
          end
        end

        it "asks for a product category" do
          within("form") do
            page.should have_selector("label[for$='product_categories']")
            page.should have_selector("select[id$='product_category_ids']")
          end
        end

        it "knows the old category" do
          within("form") do
            product.categories.each do |category|
              page.should have_selector("option[value$='#{category.id}'][selected$='selected']")
            end
          end
        end

        it "asks if the product is retired" do
          within("form") do
            page.should have_selector("label[class$='retired_check']")
            page.should have_selector("input[name$='product[retired]'][type$='checkbox']")
          end
        end

        it "knows the old retired status" do
          within("form") do
            pending "Pending implementations of retired properly"
            page.should have_selector("input[id$='product_title'][value$='#{product.title}']")
          end
        end
      end
    end

    context "show" do
      let!(:product) { Fabricate(:product) }

      before(:each) do
        visit admin_product_path(product)
      end

      it "has a link to the edit this product page" do
        page.should have_selector("a[href$='#{edit_admin_product_path(product)}']")
      end

      it "displays the add product page when clicking the link" do
        click_link("edit this product")
        current_path.should == edit_admin_product_path(product)
      end

      it "has a link to the delete this product page" do
        page.should have_selector("a[href$='#{product_path(product)}'][data-method$='delete']")
      end

      it "displays the products when clicking the link" do
        click_link("delete this product")
        current_path.should == admin_products_path
      end

      it "deletes the product when clicking the link" do
        click_link("delete this product")
        within("table#products") do
          page.should_not have_link(product.title, :href => product_path(product))
        end
      end

    end

    context "new" do

      before(:each) do
        visit new_admin_product_path
      end

      it "displays a form" do
        page.should have_selector("form")
      end

      describe "filling out and submitting the form" do

        it "asks for a title" do
          within("form") do
            page.should have_selector("label[for$='product_title']")
            page.should have_selector("input[id$='product_title']")
          end
        end

        it "asks for a product description" do
          within("form") do
            page.should have_selector("label[for$='product_description']")
            page.should have_selector("textarea[id$='product_description']")
          end
        end

        it "asks for a product price" do
          within("form") do
            page.should have_selector("label[for$='product_price']")
            page.should have_selector("input[id$='product_price']")
          end
        end

        it "asks for a product photo" do
          within("form") do
            page.should have_selector("label[for$='product_photo']")
            page.should have_selector("input[id$='product_photo']")
          end
        end

        it "asks for a product category" do
          within("form") do
            page.should have_selector("label[for$='product_categories']")
            page.should have_selector("select[id$='product_category_ids']")
          end
        end

        it "asks if the product is retired" do
          within("form") do
            page.should have_selector("label[class$='retired_check']")
            page.should have_selector("input[name$='product[retired]'][type$='checkbox']")
          end
        end

        it "saves the product name" do
          fill_in "Title",        with: "New Product Title"
          fill_in "Description",  with: "Sweet description"
          fill_in "Price",        with: "493"
          fill_in "Photo",        with: "http://adigitalnative.com/img.jpg"
          click_link_or_button "Create Product"
          page.should have_content("New Product Title")
        end

        it "saves the product description" do
          fill_in "Title",        with: "New Product Title"
          fill_in "Description",  with: "Sweet description"
          fill_in "Price",        with: "493"
          fill_in "Photo",        with: "http://adigitalnative.com/img.jpg"
          click_link_or_button "Create Product"
          page.should have_content("Sweet description")
        end

        it "saves the product price" do
          fill_in "Title",        with: "New Product Title"
          fill_in "Description",  with: "Sweet description"
          fill_in "Price",        with: "493"
          fill_in "Photo",        with: "http://adigitalnative.com/img.jpg"
          click_link_or_button "Create Product"
          page.should have_content("493")
        end

        it "saves the photo" do
          pending "TODO: Figure out advanced selectors"
          fill_in "Title",        with: "New Product Title"
          fill_in "Description",  with: "Sweet description"
          fill_in "Price",        with: "493"
          fill_in "Photo",        with: "http://adigitalnative.com/img.jpg"
          click_link_or_button "Create Product"
          page.should have_content("New Product Title")
        end

        it "saves the categories" do
          pending "TODO: Figure out multiselector submission"
          fill_in "Title",        with: "New Product Title"
          fill_in "Description",  with: "Sweet description"
          fill_in "Price",        with: "493"
          fill_in "Photo",        with: "http://adigitalnative.com/img.jpg"
          click_link_or_button "Create Product"
          page.should have_content("New Product Title")
        end
      end
    end
  end

  context "when not logged in" do
    let!(:product) { Fabricate(:product) }

    before(:each) do
      visit product_path(product)
    end

    describe "a product is added to the cart" do
      it "creates a new cart" do
        click_link_or_button("Add to Cart")
        page.should have_content(product.title)
        page.should have_content('Quantity')
      end
    end

    context "visitor tries to access the admin products list" do
      before(:each) do
        visit '/admin/products/'
      end

      it "does not allow access" do
        page.should_not have_selector("table#products")
      end

    end
  end

end