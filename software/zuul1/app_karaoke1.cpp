/*
Jasper ter Weeme
Alex Aalbertsberg
*/

#include <system.h>
#include "misc.h"
#include "mymidi.h"
#include <math.h>
#include <altera_up_avalon_video_pixel_buffer_dma.h>

class Karaoke1
{
private:
    VGATerminal vgaTerminal;
    Uart uart;
    QuadroSegment *qs;
    SDCardEx sdCard;
    MyFile *myFile;
    KarFile *karFile;
    static const uint32_t SD_BASE = ALTERA_UP_SD_CARD_AVALON_INTERFACE_0_BASE;
public:
    Karaoke1();
    void init();
    int run();
};

Karaoke1::Karaoke1()
  :
    vgaTerminal("/dev/video_character_buffer_with_dma_0"),
    uart((uint32_t *)UART_BASE),
    sdCard(ALTERA_UP_SD_CARD_AVALON_INTERFACE_0_NAME, (void *)SD_BASE)
{
    vgaTerminal.clear();
    vgaTerminal.puts("Karaoke 1\r\n");
}

void Karaoke1::init()
{
    qs = new QuadroSegment((volatile uint32_t * const)MYSEGDISP2_0_BASE);
    qs->setInt(0);
    using mstd::vector;

    if (sdCard.isPresent() && sdCard.isFAT16())
    {
        myFile = sdCard.openFile("DADDYC~1.KAR");
        karFile = new KarFile(myFile);
        karFile->read();
        
        for (vector<KarTrack>::iterator it = karFile->tracks.begin();
                it != karFile->tracks.end(); ++it)
        {
            KarTrack track = *it;
            track.parse();

            for (MIDIEventVector::iterator event = track.events.begin();
                    event != track.events.end(); ++event)
            {
                TextEvent *te = dynamic_cast<TextEvent *>(*event);
                
                if (te)
                {
                    for (size_t i = 0; i < te->length; ++i)
                    {
                        char c = te->text[i];

                        switch (c)
                        {
                        case '@':
                            break;
                        case '/':
                            vgaTerminal.puts("\r\n");
                            break;
                        case '\\':
                            vgaTerminal.puts("\r\n\r\n");
                            break;
                        default:
                            vgaTerminal.putc(c);
                            break;
                        }
                    }
                }
            }

            uint32_t chunkSize = ::Utility::be_32_toh(track.chunkSizeBE);
            qs->setHex(chunkSize);
            vgaTerminal.puts(it->toString());
            vgaTerminal.puts("\r\n");
            //break;
        }

        vgaTerminal.puts(karFile->toString());
        vgaTerminal.puts("\r\n");
    }
    else
    {
        vgaTerminal.puts("\r\nGeen SD Kaart aanwezig!");
    }
    
    mstd::vector<int> vector1(100);
    vector1.push_back(1);
    vector1.push_back(5);
    vector1.push_back(4);
    vector1.push_back(6);
    int dinges = 0;

    for (mstd::vector<int>::iterator it = vector1.begin(); it != vector1.end(); ++it)
        dinges += *it;

    uart.printf("Hello %s\r\n", "World");
    //volatile uint32_t * const pixels = (volatile uint32_t * const)SRAM_BASE;
    volatile uint8_t * const pixels8 = (volatile uint8_t * const)SRAM_BASE;
    alt_up_pixel_buffer_dma_dev *pb;
    pb = alt_up_pixel_buffer_dma_open_dev("/dev/video_pixel_buffer_dma_0");
 
    if (!pb)
        throw "Dinges";

    vgaTerminal.puts("Onzin");

    for (int i = 0; i < 1280*768; i++)
        pixels8[i] = 0x40;

    for (int x = 0; x < 680*2; x++)
    {
        const int offset = 1270; //500*1279; //= 500*1280;
        pixels8[offset + x] = 0xff;
    }
    //int x = sin(100);
    
}

int Karaoke1::run()
{
    
    return 0;
}

int main()
{
    Karaoke1 kar1;
    kar1.init();
    return kar1.run();
}


