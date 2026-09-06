@ignore
Feature: Carrito de compras

  Background:
    Given url baseUrl
    * path 'carrinhos'

  Scenario: Obetener todos los carritos disponibles
    * def utils = call read('classpath:serveRest/features/common/common-utils.feature')
    When method get
    Then status 200
    # Asegurar que la cantidad de carritos sean mayor a 0
    * assert response.quantidade > 0
    * match response.carrinhos == '#[_ > 0]'
    * def allCarts = get response.carrinhos
    * def selectedCart = utils.getRandomItem(allCarts)
    * def userIdWithCart = selectedCart.idUsuario
    * def selectedCartId = selectedCart._id

