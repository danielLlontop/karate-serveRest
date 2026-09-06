@UsersCRUD
@GetUsers
Feature: Listar Usuarios (GET /usuarios/ - /usuarios/{_id})

  Como: un administrador del sistema
  Quiero: poder obtener los usuarios a través de la API
  Para: administrar la base de datos de usuarios

  Background:
    Given url baseUrl
    * path 'usuarios'
    #Setup de utilidades
    * def userInfoSchema = read('classpath:serveRest/data/users/user-info.schema.json')
    * def userListSchema = read('classpath:serveRest/data/users/users-list.schema.json')

    # ----- Listar Usuarios (Get All) -----#

    @EC01 @HappyPath @GetUserHelper
  Scenario: Listar todos los usuarios registrados
    * def utils = call read('classpath:serveRest/features/common/common-utils.feature')
    When method get
    Then status 200
    * karate.log(response)
    * match response == userListSchema
    # Obtenemos todos los usuarios
    * def allUsers = get response.usuarios
    * match allUsers == '#[response.quantidade]' 
    # Seleccionamos un usuario de manera aleatoria
    * def selectedUser = utils.getRandomItem(allUsers)
    * karate.log('Usuario seleccionado:', selectedUser)
    # Captura de email y Id para usarlo en EC posteriores
    * def existingEmail = selectedUser.email
    * def existingUserId = selectedUser._id
    * karate.log('Email seleccionado para operaciones CRUD:' , existingEmail)
    * karate.log('ID seleccionado para operaciones CRUD:' , existingUserId)

  @EC02 @HappyPath
  Scenario: Listar todos los usuarios de tipo Administrador
    * param administrador = true
    When method get
    Then status 200
    * karate.log(response)
    * match response == userListSchema
    * match response.usuarios == '#[response.quantidade]' 
    * match each response.usuarios[*].administrador == 'true'

  # ----- Obtener un unico Usuario por ID (Get Single ID) -----#

  @EC03 @HappyPath
  Scenario: Obtener usuario por ID
    * call read('@GetUserHelper')
    * path existingUserId
    When method get
    Then status 200
    * karate.log(response)
    * match response == userInfoSchema
    * match response._id == existingUserId
    * karate.log('ID del usuario buscado', response._id)

  @EC04 @NegativeCase
  Scenario: Obtener usuario por ID Inexistente
    * def invalidId = '9999999999999999'
    * path invalidId
    When method get
    Then status 400
    * karate.log(response)
    * match response.message == '#string'
    * match response.message contains 'Usuário não encontrado'

  @EC05 @NegativeCase
  Scenario: Obtener usuario por ID diferente a 16 caracteres
    # ID con 15 caracteres
    * def invalidId = '999999999999999'
    * path invalidId
    When method get
    Then status 400
    * karate.log(response)
    * match response.id == '#string'
    * match response.id contains 'id deve ter exatamente 16 caracteres alfanuméricos'