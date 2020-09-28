<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Like extends Model
{
    public function user()
    {
        return $this->belongsTo('App\Models\User');
    }

    public function restaurant()
    {
        return $this->belongsTo('App\Models\Restaurant');
    }
}
