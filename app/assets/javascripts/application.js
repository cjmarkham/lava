// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require rails-ujs
//= require_tree .

$(function () {
    $('#add-to-cart').on('click', e => {
        e.preventDefault()
        let button = $(e.currentTarget)
        button.attr('disabled', true)

        const productId = button.attr('data-product')
        let quantity = $('input[name="quantity"]').val()

        let req = $.post('/cart_items', {
            product_id: productId,
            quantity: quantity,
        })

        req.done(res => {
            res = JSON.parse(res)

            let newCount = 0
            for (let i = 0; i < res.data.length; ++i) {
                let item = res.data[i]
                newCount += item.quantity
            }
            $('#cart-count').text(newCount)

            button.text('Success!').addClass('btn-success')
            button.attr('disabled', false)
            setTimeout(() => {
                button.text('Add to cart').removeClass('btn-success')
            }, 2000)
        })

        req.error(err => {
            err = JSON.parse(err.responseJSON)
            Flash(err['errors'][0]['detail'], 'danger')
            button.attr('disabled', false)
        })
    })


    $('.remove-from-cart').on('click', e => {
        e.preventDefault()

        const productId = $(e.currentTarget).attr('data-product')
        let button = $(e.currentTarget)
        button.text('Removing...')

        let req = $.ajax({
            url: '/cart_items/' + productId,
            type: 'DELETE',
            data: {
                product_id: productId
            },
            success: res => {
                window.location.reload()
            },
            fail: err => {
                console.error(err)
            }
        })
    })

    if ($('#card-element').length) {
        var style = {
          base: {
            fontSize: '16px',
            color: "#32325d",
          }
        };

        var card = elements.create('card', {style: style});

        card.mount('#card-element');

        card.addEventListener('change', function(event) {
          var displayError = document.getElementById('card-errors');
          if (event.error) {
            displayError.textContent = event.error.message;
          } else {
            displayError.textContent = '';
          }
        });

        $('#checkout-form').on('submit', e => {
            e.preventDefault()

            stripe.createToken(card).then(function(result) {
                if (result.error) {
                  // Inform the customer that there was an error.
                  var errorElement = document.getElementById('card-errors');
                  errorElement.textContent = result.error.message;
                } else {
                    $('input[name="token"]').val(result.token.id)
                    $(e.currentTarget).off('submit').submit()
                }
            })
        })
    }


    $('#promo-form').on('submit', e => {
        e.preventDefault()
        let form = $(e.currentTarget)
        let code = form.find('input[type="text"]').val()

        let req = $.post('/carts/apply_promotion', {
            code: code,
        })

        req.done(res => {
            window.location.reload()
        })

        req.fail(e => {
            Flash("There was an issue applying your code", "danger")
        })
    })

    $('#currency-select').on('change', e => {
        let option = $(e.currentTarget).find('option:selected').val()
        let req = $.post('/currencies', {
            code: option
        })

        req.done(() => window.location.reload())
        req.fail(err => {
            Flash(err, 'danger')
        })
    })
})

let Flash = (message, type) => {
    let container = $('.js-flash')

    container.text(message)
    container.removeClass().addClass('alert').addClass('alert-' + type).addClass('js-flash')

    container.fadeIn()

    setTimeout(() => {
        container.fadeOut()
    }, 5000)
}
