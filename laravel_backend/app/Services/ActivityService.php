<?php

namespace App\Services;

use App\Models\Activity;

class ActivityService
{
    public function log($type, $action, $description, $entityId = null, $entityType = null, $entityName = null)
    {
        return Activity::create([
            'type' => $type,
            'action' => $action,
            'description' => $description,
            'entity_id' => $entityId,
            'entity_type' => $entityType,
            'entity_name' => $entityName,
        ]);
    }
}
