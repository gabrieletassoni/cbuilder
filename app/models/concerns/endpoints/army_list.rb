class Endpoints::ArmyList < NonCrudEndpoints
  self.desc "ArmyList", :add_unit, {
    # Define the action name using openapi swagger format
    post: {
      summary: "Add Unit to Army List",
      description: "Adds a unit (profile) to the specified army list. If the profile_id is not provided, a new profile will be created from the given fighter_id.",
      operationId: "addUnit",
      tags: ["ArmyList"],
      requestBody: {
        required: true,
        content: {
          "application/json": {
            schema: {
              type: "object",
              properties: {
                id: {
                  type: "integer",
                  description: "ID of the Army List to which the unit will be added",
                },
                profile_id: {
                  type: "integer",
                  description: "ID of the Profile to add to the Army List (optional if fighter_id is provided)",
                },
                fighter_id: {
                  type: "integer",
                  description: "ID of the Fighter to create a new Profile from if profile_id is not provided",
                },
              },
            },
          },
        },
      },
      responses: {
        200 => {
          description: "Unit added successfully, it returns the updated Army List",
          # This will return the object with a message string and a params object
          content: {
            "application/json": {
              schema: {
                type: "object",
                properties: {
                  message: {
                    type: "object",
                    description: "The updated Army List object",
                    # You can define the schema of the Army List object here or reference an existing schema
                    # For simplicity, we'll just use a generic object type
                    properties: ArmyList.json_attrs.transform_values { |v| { type: "string" } },
                  },
                },
              },
            },
          },
        },
        422 => {
          description: "Unprocessable Entity - Error adding unit to Army List",
          content: {
            "application/json": {
              schema: {
                type: "object",
                properties: {
                  error: { type: "string", description: "Error message describing the issue" },
                },
              },
            },
          },
        },
      },
    },
  }

  def add_unit(params)
    @army_list = current_user.army_lists.find(params[:id])

    # 1. Trova il profilo dalla libreria dell'utente o creane uno al volo dal fighter
    if params[:profile_id]
      @profile = Profile.find(params[:profile_id])
    else
      # Creazione al volo di un profilo base non customizzato
      fighter = Fighter.find(params[:fighter_id])
      @profile = Profile.create!(user: current_user, fighter: fighter, custom_name: fighter.name)
    end

    # 2. Crea o incrementa l'entry nella lista
    entry = @army_list.list_entries.find_or_initialize_by(profile: @profile)
    entry.quantity += 1

    if entry.save
      @army_list.save # Triggera il ricalcolo della cache e le validazioni
      return { message: @army_list.as_json(ArmyList.json_attrs) }, 200
    else
      return { error: "Errore nell'aggiunta." }, 422
    end
  end
end
