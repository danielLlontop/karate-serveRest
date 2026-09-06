@UsersCRUD
@DeleteUsers
Feature: Eliminar Usuarios (DELETE /usuarios/{_id})

  Como: un administrador del sistema
  Quiero: poder eliminar usuarios a través de la API
  Para: administrar la base de datos de usuarios

    Background:
    Given url baseUrl
    * path 'usuarios'

    # ----- Eliminar Usuarios por ID (Delete by ID) -----#

  @EC13 @HappyPath
  Scenario: Eliminar Usuario
    * call read('classpath:serveRest/features/users/post-users.feature@CreateUserHelper')
    * path userIdCreated
    When method delete
    Then status 200
    * karate.log(response)
    * match response.message == '#string'
    * match response.message contains 'Registro excluído com sucesso'
    * karate.log('ID del usuario eliminado', userIdCreated)

  @EC14 @EdgeCase
  Scenario: Eliminar Usuario con ID inexistente
    * def nonExistId = '999991239999999'
    * path nonExistId
    When method delete
    Then status 200
    * karate.log(response)
    * match response.message == '#string'
    * match response.message contains 'Nenhum registro excluído'

  @EC15 @NegativeCase
  Scenario: Eliminar Usuario con carrito existente
    * call read('classpath:serveRest/features/carts/carts.feature')
    * path userIdWithCart
    When method delete
    Then status 400
    * karate.log(response)
    * match response.message == '#string'
    * match response.message contains 'Não é permitido excluir usuário com carrinho cadastrado'
    * match response.idCarrinho == selectedCartId