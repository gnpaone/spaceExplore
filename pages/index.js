import Head from 'next/head'
import Link from 'next/link';
import React, {useState} from 'react';

export default function Index(props) {

  return (
    <div>
      <Head>
        <title>Space Explore</title>
        <meta name="description" content="3D solar system in space" />
        <link rel="icon" href="/favicon.ico" />
      </Head>

      <main className='overflow-x-hidden text-lg md:text-xl'>
        {props.canvas}
      </main>
    </div>
  )
}
