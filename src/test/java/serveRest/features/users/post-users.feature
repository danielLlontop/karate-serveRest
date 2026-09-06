@UsersCRUD
@PostUsers
Feature: Crear Usuarios (POST /usuarios)
  Como: un administrador del sistema
  Quiero: poder crear usuarios a través de la API
  Para: administrar la base de datos de usuarios

    Background:
    Given url baseUrl
    * path 'usuarios'
    #Setup de utilidades
    * def userCreateResponseSchema = read('classpath:serveRest/data/users/user-create-response.schema.json')
    * def DataGen = Java.type('utils.DataGenerator')

  # ----- Crear Usuario (Post User) -----#
  
    @EC06 @HappyPath @CreateUserHelper
  Scenario: Crear Usuario
    # Setup
    * def userBody = DataGen.buildUserPayload()

    * request userBody
    When method post
    Then status 201
    * karate.log(response)
    * match response == userCreateResponseSchema
    * match response.message contains 'Cadastro realizado com sucesso'
    * def userIdCreated = response._id
    * karate.log('ID Usuario creado:', userIdCreated)

  @EC07 @NegativeCase
  Scenario: Crear Usuario con email existente
    * call read('classpath:serveRest/features/users/get-users.feature@GetUserHelper')
    * def userBody = DataGen.buildUserPayload()
    * set userBody.email = existingEmail
    * request userBody
    When method post
    Then status 400
    * match response.message == '#string'
    * match response.message == '#string? _.includes("Este email já está sendo usado")'

  @EC08 @NegativeCase
  Scenario: Crear Usuario con email invalido
    * def invalidEmail = DataGen.getInvalidEmail('NO_EXTENSION')
    * def userBody = DataGen.buildUserPayload()
    * set userBody.email = invalidEmail
  
    * request userBody
    When method post
    Then status 400
    * match response.email == '#string'
    * match response.email contains 'email deve ser um email válido'
