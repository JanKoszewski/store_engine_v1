require 'spec_helper'

describe "Using the shopping cart" do

  context "signed in as a normal user" do
    let!(:user) { Fabricate(:user, admin: true) }

    before(:each) do
      visit signin_path
      fill_in "Email",        with: user.email
      fill_in "Password",     with: user.password
      click_button "Sign in"
    end

    context "when I'm checking out" do
      let!(:product) { Fabricate(:product) }

      before(:each) do 
        visit product_path(product)
        click_link_or_button("Add to Cart")
        click_link_or_button("Place Order")
      end

      describe "and I update shipping information" do
        it "updates the address when I click 'ship to this address" do
          fill_in "shipping_address_line_1", with: "1234 Lane"
          click_link_or_button('Ship to this address')
          page.should have_content("Shipping information saved!")
        end

        it "saves the shipping address when I submit the order" do
          fill_in "shipping_address_line_1", with: "1234 Lane"
          click_link_or_button('Ship to this address')
          click_link_or_button('Place Order')
          # TODO: Return to this when shipping is integrated
          # page.should have_content("1234 Lane")
        end
      end
    end
  end

  context "when I'm on the main cart page" do

    # it "has a link to return to the product list" do
    #   page.should have_selector("a#to_products")
    # end

    context "and the cart contains at least one product" do

      let(:product) { Fabricate(:product, :price => 50) } 
      before(:each) { visit product_path(product)
                      click_link_or_button "Add to Cart"
                    }
      it "has a button to remove the product from the cart" do
        page.should have_selector("#product_#{product.id}_remove")
      end

      it "can remove a product from the cart" do
        pending "Something funky with passing values going on here."
        # within("##{}")
        click_link_or_button "Remove Item"
      end
    end

    describe "the 'destroy cart' button" do

      before(:each) do
        visit cart_path
      end

      it "exists" do
        page.should have_selector('#destroy_cart')
      end

      let(:product) { Fabricate(:product) }
      it "clears the cart" do
        visit product_path(product)
        click_link_or_button("Add to Cart")
        page.should have_content(product.title)
        click_link_or_button("Clear Cart")
        page.should_not have_content(product.title)
      end
    end
  end
  context "When I'm on a product page" do
    let(:product) { Fabricate(:product, :price => 10) }

    before(:each) { visit product_path(product) }

    context "And I click 'add to cart'" do
      before(:each) { click_link_or_button "Add to Cart" }

      context "And the cart was empty" do
        it "takes me to the cart page"do
          page.should have_selector("#cart")
        end
        it "shows me the product in my cart" do
          within("#cart") do
            page.should have_content(product.title)
          end
        end

        it "shows the quantity of the product in my cart" do
          within("#cart") do
            page.should have_selector("##{product.id}_quant")
          end
        end
        it "shows the total price of the product in my cart" do
          within("#cart") do
            page.should have_content(product.price)
          end
        end
      end

      context "when I add multiple items to the cart" do
        let(:second_product) { Fabricate(:product, :price => 15) }

        before(:each) do
          visit product_path(product)
          click_link_or_button "Add to Cart"

          visit product_path(second_product)
          click_link_or_button "Add to Cart"
        end

        it "takes me to the cart page" do
          page.should have_selector("#cart")
        end        

        it "shows each item in the cart" do
          within("#cart") do
            page.should have_content(product.title)
            page.should have_content(second_product.title)
          end
        end

        it "shows the quantity of the products in my cart" do
          visit product_path(product)
          click_link_or_button "Add to Cart"

          within("#cart") do
            within ("##{product.id}_quant") do
              pending "Need to return to this to figure out why it's breaking"
              page.should have_content(3)
              # Content is 3 b/c this is added twice - once @ top context & once halfway down
            end
          end
        end
        
        it "shows the total price of the specific product in my cart" do
          within ("#cart") do
            within ("##{product.id}_total") do
              page.should have_content(product.price * 2)
            end
          end
        end

        it "shows the total price of all products in my cart" do
          product.price = 10
          second_product.price = 15


          within ("#total") do
            page.should have_content((product.price * 2) + (second_product.price) )
          end
        end
      end
    end

    context "and the place order button is clicked" do
      # before(:each) { click_link_or_button("Place Order") }

      it "creates an order" do
        pending "This should be moved to an order spec"
        current_orders = Order.count
        click_link_or_button("Place Order")
        current_orders.should == current_orders + 1
      end

    end
  end
end