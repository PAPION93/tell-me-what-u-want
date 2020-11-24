<?php

namespace Tests\Feature;

use Tests\TestCase;
use App\Models\Restaurant;
use App\Models\Image;

class RestaurantApiUnitTest extends TestCase
{
    public function test_it_can_create_an_restaurant()
    {
        $data = [
            'name' => $this->faker->name,
            'address' => $this->faker->address,
            'lat' => $this->faker->latitude,
            'lng' => $this->faker->longitude,
            'description' => $this->faker->sentence,
        ];

        $this->post('/api/v1/restaurants', $data)
            ->assertStatus(201)
            ->assertJson($data);
    }

    public function test_get_restaurants()
    {
        Restaurant::factory()->count(5)->create();

        $this->get('/api/v1/restaurants')
            ->assertOk()
            ->assertJsonStructure([
                'current_page',
                'data' => [[
                    'id',
                    'name',
                    'address',
                    'lat',
                    'lng',
                    'description',
                ]]]);
    }

    public function test_get_restaurants_with_images()
    {
        Restaurant::factory()
            ->create()
            ->each(function ($restaurant) {
                Image::factory()
                    ->create([
                        'restaurant_id' => $restaurant
                    ]);
            });

        $this->get('/api/v1/restaurants')
            ->assertOk()
            ->assertJsonStructure([
                'current_page',
                'data' => [[
                    'id',
                    'name',
                    'address',
                    'lat',
                    'lng',
                    'description',
                    'images' => [[
                        'id',
                        'restaurant_id',
                        'hash_name',
                        'original_name',
                    ]]
                ]]
            ]);
    }
}