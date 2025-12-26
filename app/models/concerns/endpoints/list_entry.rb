class Endpoints::ListEntry < NonCrudEndpoints
  self.desc "ListEntry", :add_equipment_to_entry, {
    post: {
      summary: "Aggiungi Equipaggiamento a Riga Lista",
      description: "Aggiunge un pezzo di equipaggiamento alla riga della lista, se i requisiti e i limiti lo permettono.",
      operationId: "addEquipmentToEntry",
      tags: ["ListEntry"],
      requestBody: {
        required: true,
        content: {
          "application/json": {
            schema: {
              type: "object",
              properties: {
                list_entry_id: {
                  type: "integer",
                  description: "ID della riga della lista a cui aggiungere l'equipaggiamento",
                },
                equipment_id: {
                  type: "integer",
                  description: "ID dell'equipaggiamento da aggiungere",
                },
              },
              required: ["list_entry_id", "equipment_id"],
            },
          },
        },
      },
      responses: {
        200 => {
          description: "Equipaggiamento aggiunto con successo",
          content: {
            "application/json": {
              schema: {
                type: "object",
                properties: {
                  success: { type: "boolean" },
                },
              },
            },
          },
        },
        400 => {
          description: "Errore di validazione",
          content: {
            "application/json": {
              schema: {
                type: "object",
                properties: {
                  success: { type: "boolean" },
                  error: { type: "string" },
                },
              },
            },
          },
        },
        404 => {
          description: "Riga o Equipaggiamento non trovati",
          content: {
            "application/json": {
              schema: {
                type: "object",
                properties: {
                  success: { type: "boolean" },
                  error: { type: "string" },
                },
              },
            },
          },
        },
      },
    },
  }

  def add_equipment_to_entry(params)
    list_entry = ListEntry.find_by(id: params[:list_entry_id])
    return { success: false, error: "Riga non trovata" }, 404 unless list_entry
    equipment = Equipment.find_by(id: params[:equipment_id])
    return { success: false, error: "Equipaggiamento non trovato" }, 404 unless equipment
    fighter = list_entry.profile.fighter

    # 1. Verifica Requisiti (es. "Solo Maghi")
    unless equipment.equipable_by?(fighter)
      return { success: false, error: "Requisiti non soddisfatti" }, 400
    end

    # 2. Verifica Limiti (es. "Solo 1 Reliquia per armata")
    if equipment.is_relic? && list_entry.army_list.has_relic?
      return { success: false, error: "L'armata ha già una reliquia" }, 400
    end

    # 3. Aggiungi
    list_entry.added_equipment << equipment
    list_entry.save # Triggera ricalcolo punti della lista
    return { success: true }, 200
  end
end
