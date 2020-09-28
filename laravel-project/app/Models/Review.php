<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Review extends Model
{
    protected $fillable = [
        'user_id',
        'restaurant_id',
        'star',
        'content',
    ];
    
    public function user()
    {
        return $this->belongsTo('App\Models\User');
    }

    public function restaurant()
    {
        return $this->belongsTo('App\Models\Restaurant');
    }
}
