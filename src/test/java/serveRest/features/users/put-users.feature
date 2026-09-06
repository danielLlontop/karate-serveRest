@UsersCRUD
@PutUsers
Feature: Actualizar Usuarios (PUT /usuarios/{_id})

  Como: un administrador del sistema
  Quiero: poder editar usuarios a través de la API
  Para: administrar la base de datos de usuarios

    Background:
    Given url baseUrl
    * path 'usuarios'
    #Setup de utilidades
    * def userCreateResponseSchema = read('classpath:serveRest/data/users/user-create-response.schema.json')
    * def DataGen = Java.type('utils.DataGenerator')

# ----- Editar/Crear Usuario (Put User) -----#

  @EC09 @HappyPath
  Scenario: Editar Usuario
    * call read('classpath:serveRest/features/users/post-users.feature@CreateUserHelper')
    * def userBody = DataGen.buildUserPayload()

    * path userIdCreated
    * request userBody
    When method put
    Then status 200
    * karate.log(response)
    * match response.message == '#string'
    * match response.message contains 'Registro alterado com sucesso'
    * karate.log('Usuario actualizado correctamente con ID:', userIdCreated)

  @EC10 @NegativeCase
  Scenario: Editar Usuario con email invalido
    * call read('classpath:serveRest/features/users/post-users.feature@CreateUserHelper')
    * def invalidEmail = DataGen.getInvalidEmail('DOUBLE_AT')
    * def userBody = DataGen.buildUserPayload()
    * set userBody.email = invalidEmail

    * path userIdCreated
    * request userBody
    When method put
    Then status 400
    * karate.log(response)
    * match response.email == '#string'
    * match response.email contains 'email deve ser um email válido'

  @EC11 @EdgeCase
  Scenario: Editar con id no existente creara el usuario
    * def userBody = DataGen.buildUserPayload()
    * def nonExistId = '999999999999abc'
    
    * path nonExistId
    * request userBody
    When method put
    Then status 201
    * karate.log(response)
    * match response == userCreateResponseSchema
    * match response.message contains 'Cadastro realizado com sucesso'
    # ID debe ser de 16 digitos
    * match response._id == '#regex ^[a-zA-Z0-9]{16}$'

  @EC12 @EdgeCase
  Scenario: Editar con id no existente pero con email existente
    * call read('classpath:serveRest/features/users/get-users.feature@GetUserHelper')
    * def userBody = DataGen.buildUserPayload()
    * set userBody.email = existingEmail
    * def nonExistId = 'abc999999999999'

    * path nonExistId
    * request userBody
    When method put
    Then status 400
    * karate.log(response)
    * match response.message == '#string'
    * match response.message contains 'Este email já está sendo usado'