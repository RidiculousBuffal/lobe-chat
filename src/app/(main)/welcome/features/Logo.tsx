'use client';

// import dynamic from 'next/dynamic';
import Image from 'next/image';
import { memo } from 'react';
import { Center } from 'react-layout-kit';

import logoUrl from '@/const/cathayLogo';

// const LogoThree = dynamic(() => import('@lobehub/ui/es/LogoThree'), {ssr: false});
// const LogoSpline = dynamic(() => import('@lobehub/ui/es/LogoThree/LogoSpline'), { ssr: false });

const Logo = memo<{ mobile?: boolean }>(({ mobile }) => {
  return mobile ? (
    <Center height={240} width={240}>
      {/*<LogoThree size={240}/>*/}
      <Image
        alt="Cathay Logo"
        height={240}
        layout="responsive" // 适应容器尺寸
        src={logoUrl}
        width={400} // 动态计算宽度
      />
    </Center>
  ) : (
    <Center
      style={{
        height: `min(482px, 40vw)`,
        marginBottom: '-10%',
        marginTop: '-20%',
        position: 'relative',
        width: `min(976px, 80vw)`,
      }}
    >
      {/*<LogoSpline height={'min(482px, 40vw)'} width={'min(976px, 80vw)'} />*/}
      <Image
        alt="Cathay Logo"
        height={482}
        layout="responsive" // 适应容器尺寸
        src={logoUrl}
        width={976} // 动态计算宽度
      />
    </Center>
  );
});

export default Logo;
