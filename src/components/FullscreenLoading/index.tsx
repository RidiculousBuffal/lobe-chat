import { Icon } from '@lobehub/ui';
// import {LobeChat} from '@lobehub/ui/brand';
import { Loader2 } from 'lucide-react';
import Image from 'next/image';
import { memo } from 'react';
import { Center, Flexbox } from 'react-layout-kit';

import logoUrl from '@/const/cathayLogo';

const FullscreenLoading = memo<{ title?: string }>(({ title }) => {
  return (
    <Flexbox height={'100%'} style={{ userSelect: 'none' }} width={'100%'}>
      <Center flex={1} gap={12} width={'100%'}>
        {/*<LobeChat size={48} type={'combine'} />*/}
        <Image
          alt="Cathay Logo"
          height={24}
          // layout="responsive" // 适应容器尺寸
          src={logoUrl}
          width={40} // 动态计算宽度
        />
        <Center gap={16} horizontal>
          <Icon icon={Loader2} spin />
          {title}
        </Center>
      </Center>
    </Flexbox>
  );
});

export default FullscreenLoading;
